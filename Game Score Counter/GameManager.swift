//
//  GameManager.swift
//  Game Score Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import Foundation
import SwiftUI
import UIKit

@Observable
class GameManager {
    var players: [Player] = []
    var targetScore: Int = 200
    var currentRound: Int = 0
    var gamePhase: GamePhase = .setup
    var roundHistory: [RoundHistory] = []
    var winner: Player?
    var gameSettings: GameSettings = GameSettings()
    var gameHistory: [Game] = []
    var ongoingGames: [Game] = []
    
    private let playersKey = "yaniv_players"
    private let targetScoreKey = "yaniv_target_score"
    private let currentRoundKey = "yaniv_current_round"
    private let gamePhaseKey = "yaniv_game_phase"
    private let roundHistoryKey = "yaniv_round_history"
    private let gameSettingsKey = "yaniv_game_settings"
    private let gameHistoryKey = "yaniv_game_history"
    private let ongoingGamesKey = "yaniv_ongoing_games"
    
    init() {
        loadGameState()
    }
    
    // MARK: - Game Setup
    
    func startNewGame(targetScore: Int, players: [Player], settings: GameSettings = GameSettings()) {
        self.targetScore = targetScore
        self.players = players.map { Player(id: $0.id, name: $0.name, score: 0, isEliminated: false, completionDate: nil) }
        self.currentRound = 0
        self.gamePhase = .playing
        self.roundHistory = []
        self.winner = nil
        self.gameSettings = settings
        saveGameState()
    }
    
    func resetGame() {
        players = []
        targetScore = 200
        currentRound = 0
        gamePhase = .setup
        roundHistory = []
        winner = nil
        gameSettings = GameSettings()
        saveGameState()
    }
    
    func pauseGame() {
        let game = Game(players: players, targetScore: targetScore, roundHistory: roundHistory, winner: winner, gameSettings: gameSettings)
        ongoingGames.append(game)
        resetGame()
        saveGameState()
    }
    
    func endGame() {
        // Determine the winner: the active player with the lowest score
        let activePlayers = getActivePlayers()
        if let gameWinner = activePlayers.min(by: { $0.score < $1.score }) {
            self.winner = gameWinner
        }
        
        self.gamePhase = .finished
        
        let game = Game(players: players, targetScore: targetScore, roundHistory: roundHistory, winner: winner, gameSettings: gameSettings)
        gameHistory.append(game)
        // Do not reset the game state immediately, so the UI can update
        // resetGame() 
        saveGameState()
    }
    
    func loadGame(game: Game) {
        self.players = game.players
        self.targetScore = game.targetScore
        self.roundHistory = game.roundHistory
        self.winner = game.winner
        self.gameSettings = game.gameSettings
        self.currentRound = game.roundHistory.count
        self.gamePhase = .playing
        ongoingGames.removeAll { $0.id == game.id }
        saveGameState()
    }
    
    func deleteOngoingGame(_ game: Game) {
        ongoingGames.removeAll { $0.id == game.id }
        saveGameState()
    }
    
    // MARK: - Scoring
    
    func addRound(scoreChanges: [UUID: Int]) {
        guard gamePhase == .playing else { return }
        
        currentRound += 1
        var roundScoreChanges: [PlayerScoreChange] = []
        var eliminatedPlayers: [Player] = []
        
        for (playerId, points) in scoreChanges {
            guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else { continue }
            
            let player = players[playerIndex]
            let oldScore = player.score
            let wasEliminatedBefore = player.isEliminated
            var newScore = oldScore + points
            
            // Check if player crosses elimination threshold
            let crossesEliminationThreshold = !wasEliminatedBefore && checkBoundary(score: newScore, target: targetScore, condition: gameSettings.boundaryCondition)
            
            // Track bonus reduction if applied
            var bonusReduction: Int? = nil
            
            // Game Mode Logic
            if gameSettings.gameMode == .scoreLimitWins {
                // In "First to [Score] Wins" mode:
                // - No elimination threshold in the traditional sense (elimination is just "finished")
                // - If triggered, they finish the race.
                
                // Allow bonuses still? Assuming yes.
                 if !player.isEliminated { // Using isEliminated as "Finished" or "Out of Play" flag
                    // Player is still active, check for score bonuses
                     if gameSettings.penaltyEnabled && newScore > 0 && newScore % gameSettings.penaltyInterval.rawValue == 0 && points > 0 {
                         let reduction: Int
                         switch gameSettings.penaltyReduction {
                         case .fixed(let amount):
                             reduction = amount
                         case .half:
                             reduction = newScore / 2
                         }
                         
                         if reduction > 0 {
                             bonusReduction = reduction
                             newScore -= reduction
                         }
                     }
                     players[playerIndex].score = newScore
                     
                     // Check if finished
                     if checkBoundary(score: newScore, target: targetScore, condition: gameSettings.boundaryCondition) {
                         players[playerIndex].isEliminated = true // Mark as "Finished" (Out of active play)
                         players[playerIndex].completionDate = Date()
                     }
                 }
                
            } else {
                // Standard Yaniv (First to [Score] Loses)
                
                // If player crosses elimination threshold, eliminate them immediately (no penalties)
                if crossesEliminationThreshold {
                    players[playerIndex].score = newScore
                    players[playerIndex].isEliminated = true
                } else if !wasEliminatedBefore {
                    // Player is still active, check for score bonuses
                    if gameSettings.penaltyEnabled && newScore > 0 && newScore % gameSettings.penaltyInterval.rawValue == 0 && points > 0 {
                        let reduction: Int
                        switch gameSettings.penaltyReduction {
                        case .fixed(let amount):
                            reduction = amount
                        case .half:
                            reduction = newScore / 2
                        }
                        
                        if reduction > 0 {
                            bonusReduction = reduction
                            newScore -= reduction
                        }
                    }
                    
                    // Update player score
                    players[playerIndex].score = newScore
                    
                    // Double-check elimination after penalty (in case penalty somehow didn't prevent crossing threshold)
                    // This should be rare but handles edge cases
                    if checkBoundary(score: newScore, target: targetScore, condition: gameSettings.boundaryCondition) {
                        players[playerIndex].isEliminated = true
                    }
                } else {
                    // Player was already eliminated, just update score without penalties
                    players[playerIndex].score = newScore
                }
            }
            
            // Track if elimination happened in this round
            let wasEliminated = !wasEliminatedBefore && players[playerIndex].isEliminated
            
            // Calculate points shown in history (net change)
            let pointsDisplayed = newScore - oldScore
            
            roundScoreChanges.append(
                PlayerScoreChange(
                    playerId: playerId,
                    playerName: player.name,
                    pointsAdded: pointsDisplayed,
                    wasEliminated: wasEliminated,
                    bonusReduction: bonusReduction
                )
            )
            
            if wasEliminated {
                eliminatedPlayers.append(players[playerIndex])
            }
        }
        
        let history = RoundHistory(
            roundNumber: currentRound,
            scoreChanges: roundScoreChanges
        )
        roundHistory.append(history)
        
        checkGameEnd()
        saveGameState()
        
        // Haptic feedback for eliminations
        if !eliminatedPlayers.isEmpty {
            HapticHelper.notification(.warning)
        }
    }
    
    func undoLastRound() {
        guard let lastRound = roundHistory.last else { return }
        
        // Reverse score changes
        for scoreChange in lastRound.scoreChanges {
            if let playerIndex = players.firstIndex(where: { $0.id == scoreChange.playerId }) {
                players[playerIndex].score = players[playerIndex].score - scoreChange.pointsAdded
                
                // Restore elimination status if player was eliminated in this round
                if scoreChange.wasEliminated {
                    players[playerIndex].isEliminated = false
                }
            }
        }
        
        roundHistory.removeLast()
        currentRound = max(0, currentRound - 1)
        
        // Check if game should still be finished
        if gamePhase == .finished {
            checkGameEnd()
        }
        
        saveGameState()
    }
    
    private func checkGameEnd() {
        if gameSettings.gameMode == .scoreLimitWins {
            // "First to [Score] Wins" Logic
            
            let activePlayers = players.filter { !$0.isEliminated }
            
            if activePlayers.count <= 1 {
                let totalPlayers = players.count
                if (totalPlayers > 1 && activePlayers.count <= 1) || (totalPlayers == 1 && activePlayers.isEmpty) {
                    
                    // Winner is the one with EARLIEST completionDate.
                    let finishedPlayers = players.filter { $0.completionDate != nil }
                    winner = finishedPlayers.min(by: { $0.completionDate! < $1.completionDate! })
                    
                    // If no one finished (edge case?), use score?
                    if winner == nil {
                         winner = players.max(by: { $0.score < $1.score }) // Should not happen in this logic path ideally
                    }
                    
                    gamePhase = .finished
                    
                    let game = Game(players: players, targetScore: targetScore, roundHistory: roundHistory, winner: winner, gameSettings: gameSettings)
                    gameHistory.append(game)
                    
                    HapticHelper.notification(.success)
                }
            }
            
        } else {
            // "First to [Score] Loses" Logic (Original Yaniv)
            let activePlayers = players.filter { !$0.isEliminated }
            
            if activePlayers.count == 1 {
                gamePhase = .finished
                winner = activePlayers.first
                let game = Game(players: players, targetScore: targetScore, roundHistory: roundHistory, winner: winner, gameSettings: gameSettings)
                gameHistory.append(game)
                
                // Haptic feedback for winner
                HapticHelper.notification(.success)
            } else if activePlayers.isEmpty {
                gamePhase = .finished
                // All players eliminated - use player with lowest score
                winner = players.min(by: { $0.score < $1.score })
                let game = Game(players: players, targetScore: targetScore, roundHistory: roundHistory, winner: winner, gameSettings: gameSettings)
                gameHistory.append(game)
            }
        }
    }
    
    func getActivePlayers() -> [Player] {
        players.filter { !$0.isEliminated }
    }
    
    func getEliminatedPlayers() -> [Player] {
        players.filter { $0.isEliminated }
    }
    
    func deleteGame(_ game: Game) {
        gameHistory.removeAll { $0.id == game.id }
        saveGameState()
    }
    
    private func checkBoundary(score: Int, target: Int, condition: BoundaryCondition) -> Bool {
        switch condition {
        case .cross:
            return score > target
        case .reach:
            return score >= target
        }
    }
    
    // MARK: - Persistence
    
    private func saveGameState() {
        // Save players
        if let encoded = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(encoded, forKey: playersKey)
        }
        
        // Save other state
        UserDefaults.standard.set(targetScore, forKey: targetScoreKey)
        UserDefaults.standard.set(currentRound, forKey: currentRoundKey)
        UserDefaults.standard.set(gamePhase.rawValue, forKey: gamePhaseKey)
        
        // Save round history
        if let encoded = try? JSONEncoder().encode(roundHistory) {
            UserDefaults.standard.set(encoded, forKey: roundHistoryKey)
        }
        
        // Save game settings
        if let encoded = try? JSONEncoder().encode(gameSettings) {
            UserDefaults.standard.set(encoded, forKey: gameSettingsKey)
        }
        
        // Save game history
        if let encoded = try? JSONEncoder().encode(gameHistory) {
            UserDefaults.standard.set(encoded, forKey: gameHistoryKey)
        }
        
        // Save ongoing games
        if let encoded = try? JSONEncoder().encode(ongoingGames) {
            UserDefaults.standard.set(encoded, forKey: ongoingGamesKey)
        }
    }
    
    private func loadGameState() {
        // Load players
        if let data = UserDefaults.standard.data(forKey: playersKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            players = decoded
        }
        
        // Load other state
        targetScore = UserDefaults.standard.integer(forKey: targetScoreKey)
        if targetScore == 0 { targetScore = 200 } // Default
        
        currentRound = UserDefaults.standard.integer(forKey: currentRoundKey)
        
        if let phaseRaw = UserDefaults.standard.string(forKey: gamePhaseKey),
           let phase = GamePhase(rawValue: phaseRaw) {
            gamePhase = phase
        }
        
        // Load round history
        if let data = UserDefaults.standard.data(forKey: roundHistoryKey),
           let decoded = try? JSONDecoder().decode([RoundHistory].self, from: data) {
            roundHistory = decoded
        }
        
        // Load game settings
        if let data = UserDefaults.standard.data(forKey: gameSettingsKey),
           let decoded = try? JSONDecoder().decode(GameSettings.self, from: data) {
            gameSettings = decoded
        }
        
        // Load game history
        if let data = UserDefaults.standard.data(forKey: gameHistoryKey),
            let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            gameHistory = decoded
        }
        
        // Load ongoing games
        if let data = UserDefaults.standard.data(forKey: ongoingGamesKey),
            let decoded = try? JSONDecoder().decode([Game].self, from: data) {
            ongoingGames = decoded
        }
        
        // Restore winner if game is finished
        if gamePhase == .finished {
            checkGameEnd()
        }
    }
}


