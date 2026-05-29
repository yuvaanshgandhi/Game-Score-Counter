//
//  StatisticsView.swift
//  Game Score Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import SwiftUI

struct StatisticsView: View {
    let gameHistory: [Game]
    
    init(gameHistory: [Game]) {
        self.gameHistory = gameHistory
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                LiquidGlassBackground(color: .orange, intensity: 0.5)
                
                if gameHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No statistics yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Play some games to see your stats.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else {
                    globalStatistics
                }
            }
            .navigationTitle("Global Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }

    }
    
    private var globalStatistics: some View {
        VStack {
            List {
                let allPlayers = gameHistory.flatMap { $0.players }.reduce(into: [String: Player]()) { result, player in
                    result[player.name] = player
                }.values.sorted { $0.name < $1.name }
                
                ForEach(allPlayers) { player in
                    PlayerStatsCard(player: player, gameHistory: gameHistory)
                        .padding(16)
                        .glassEffect(in: .rect(cornerRadius: 22))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .background(Color.clear)
        }
    }
}

struct PlayerStatsCard: View {
    let player: Player
    let gameHistory: [Game]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(player.name)
                .font(.headline)
            
            let gamesPlayed = gameHistory.filter { $0.players.contains(where: { $0.name == player.name }) }.count
            let gamesWon = gameHistory.filter { $0.winner?.name == player.name }.count
            let winPercentage = gamesPlayed > 0 ? (Double(gamesWon) / Double(gamesPlayed)) * 100 : 0
            
            let totalScore = gameHistory.flatMap { $0.roundHistory }.flatMap { $0.scoreChanges }.filter { $0.playerName == player.name }.reduce(0) { $0 + $1.pointsAdded }
            let roundsPlayed = gameHistory.flatMap { $0.roundHistory }.filter { $0.scoreChanges.contains(where: { $0.playerName == player.name }) }.count
            let roundsWon = gameHistory.flatMap { $0.roundHistory }.filter { round in
                let winner = round.scoreChanges.min(by: { $0.pointsAdded < $1.pointsAdded })
                return winner?.playerName == player.name
            }.count
            let roundWinPercentage = roundsPlayed > 0 ? (Double(roundsWon) / Double(roundsPlayed)) * 100 : 0
            let averageScore = roundsPlayed > 0 ? Double(totalScore) / Double(roundsPlayed) : 0
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Games Played")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(gamesPlayed)")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Games Won")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(gamesWon)")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Win Percentage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", winPercentage))
                        .font(.headline)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Average Score per Round")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", averageScore))
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Round Win Percentage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f%%", roundWinPercentage))
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    // Explicit preview data to avoid ambiguous types
    let manager = GameManager()

    let alice: Player = Player(name: "Alice")
    let bob: Player = Player(name: "Bob")
    let charlie: Player = Player(name: "Charlie")

    // Capture stable UUIDs from players for score change entries
    let aliceId: UUID = alice.id
    let bobId: UUID = bob.id
    let charlieId: UUID = charlie.id

    // Round 1 score changes
    let round1ScoreChangeAlice: PlayerScoreChange = PlayerScoreChange(playerId: aliceId, playerName: "Alice", pointsAdded: 10)
    let round1ScoreChangeBob: PlayerScoreChange = PlayerScoreChange(playerId: bobId, playerName: "Bob", pointsAdded: 25)

    // Round 2 score changes
    let round2ScoreChangeAlice: PlayerScoreChange = PlayerScoreChange(playerId: aliceId, playerName: "Alice", pointsAdded: 20)
    let round2ScoreChangeCharlie: PlayerScoreChange = PlayerScoreChange(playerId: charlieId, playerName: "Charlie", pointsAdded: 5)

    // Rounds
    let round1: RoundHistory = RoundHistory(roundNumber: 1, scoreChanges: [round1ScoreChangeAlice, round1ScoreChangeBob])
    let round2: RoundHistory = RoundHistory(roundNumber: 2, scoreChanges: [round2ScoreChangeAlice, round2ScoreChangeCharlie])

    // Games
    let game1: Game = Game(
        players: [alice, bob],
        targetScore: 200,
        roundHistory: [round1],
        winner: alice
    )

    let game2: Game = Game(
        players: [alice, charlie],
        targetScore: 200,
        roundHistory: [round2],
        winner: charlie
    )

    // Assign explicit type to history to avoid inference issues
    let history: [Game] = [game1, game2]

    manager.gameHistory = history
    return StatisticsView(gameHistory: manager.gameHistory)
}
