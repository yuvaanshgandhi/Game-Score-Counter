//
//  Models.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var score: Int
    var isEliminated: Bool
    var completionDate: Date?
    
    init(id: UUID = UUID(), name: String, score: Int = 0, isEliminated: Bool = false, completionDate: Date? = nil) {
        self.id = id
        self.name = name
        self.score = score
        self.isEliminated = isEliminated
        self.completionDate = completionDate
    }
}

struct RoundHistory: Identifiable, Codable, Equatable {
    let id: UUID
    let roundNumber: Int
    let timestamp: Date
    let scoreChanges: [PlayerScoreChange]
    
    init(id: UUID = UUID(), roundNumber: Int, timestamp: Date = Date(), scoreChanges: [PlayerScoreChange]) {
        self.id = id
        self.roundNumber = roundNumber
        self.timestamp = timestamp
        self.scoreChanges = scoreChanges
    }
}

struct PlayerScoreChange: Identifiable, Codable, Equatable {
    let id: UUID
    let playerId: UUID
    let playerName: String
    let pointsAdded: Int
    let wasEliminated: Bool
    let bonusReduction: Int? // Amount of points reduced due to bonus/penalty
    
    init(id: UUID = UUID(), playerId: UUID, playerName: String, pointsAdded: Int, wasEliminated: Bool = false, bonusReduction: Int? = nil) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.pointsAdded = pointsAdded
        self.wasEliminated = wasEliminated
        self.bonusReduction = bonusReduction
    }
}

enum GamePhase: String, Codable {
    case setup
    case playing
    case finished
    case paused
}

enum PenaltyInterval: Int, Codable, CaseIterable {
    case fifty = 50
    case hundred = 100
    
    var displayName: String {
        "\(rawValue)"
    }
}

enum PenaltyReduction: Codable, Equatable {
    case fixed(Int)
    case half
    
    var displayName: String {
        switch self {
        case .fixed(let amount):
            return "\(amount)"
        case .half:
            return "Half"
        }
    }
}

enum BoundaryCondition: String, Codable, CaseIterable {
    case cross
    case reach
    
    var displayName: String {
        switch self {
        case .cross: return "Cross (>)"
        case .reach: return "Reach (>=)"
        }
    }
}

struct Game: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let players: [Player]
    let targetScore: Int
    let roundHistory: [RoundHistory]
    let winner: Player?
    let gameSettings: GameSettings
    
    init(id: UUID = UUID(), date: Date = Date(), players: [Player], targetScore: Int, roundHistory: [RoundHistory], winner: Player?, gameSettings: GameSettings = GameSettings()) {
        self.id = id
        self.date = date
        self.players = players
        self.targetScore = targetScore
        self.roundHistory = roundHistory
        self.winner = winner
        self.gameSettings = gameSettings
    }
}

struct GameSettings: Codable, Equatable {
    var penaltyEnabled: Bool = false
    var penaltyInterval: PenaltyInterval = .fifty
    var penaltyReduction: PenaltyReduction = .fixed(50)
    var gameMode: GameMode = .scoreLimitLoses
    var boundaryCondition: BoundaryCondition = .cross // Default matches original logic (> target)
    
    init(penaltyEnabled: Bool = false, penaltyInterval: PenaltyInterval = .fifty, penaltyReduction: PenaltyReduction = .fixed(50), gameMode: GameMode = .scoreLimitLoses, boundaryCondition: BoundaryCondition = .cross) {
        self.penaltyEnabled = penaltyEnabled
        self.penaltyInterval = penaltyInterval
        self.penaltyReduction = penaltyReduction
        self.gameMode = gameMode
        self.boundaryCondition = boundaryCondition
    }
}

enum GameMode: String, Codable, CaseIterable {
    case scoreLimitLoses
    case scoreLimitWins
    
    var displayName: String {
        switch self {
        case .scoreLimitLoses: return "Loses"
        case .scoreLimitWins: return "Wins"
        }
    }
}

