//
//  StatisticsView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import SwiftUI

struct StatisticsView: View {
    let gameHistory: [Game]
    
    var body: some View {
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
                List {
                    let allPlayers = gameHistory.flatMap { $0.players }.reduce(into: [String: Player]()) { result, player in
                        result[player.name] = player
                    }.values.sorted { $0.name < $1.name }
                    
                    ForEach(allPlayers) { player in
                        PlayerStatsCard(player: player, gameHistory: gameHistory)
                            .modifier(GlassCardModifier())
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
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
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
            }
        }
    }
}

#Preview {
    let manager = GameManager()
    manager.gameHistory = [
        Game(
            players: [Player(name: "Alice"), Player(name: "Bob")],
            targetScore: 200,
            roundHistory: [RoundHistory(roundNumber: 1, scoreChanges: [PlayerScoreChange(playerId: UUID(), playerName: "Alice", pointsAdded: 10)])],
            winner: Player(name: "Alice")
        ),
        Game(
            players: [Player(name: "Alice"), Player(name: "Charlie")],
            targetScore: 200,
            roundHistory: [RoundHistory(roundNumber: 1, scoreChanges: [PlayerScoreChange(playerId: UUID(), playerName: "Alice", pointsAdded: 20)])],
            winner: Player(name: "Charlie")
        )
    ]
    return StatisticsView(gameHistory: manager.gameHistory)
}
