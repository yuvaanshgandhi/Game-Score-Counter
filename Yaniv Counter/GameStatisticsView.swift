//
//  GameStatisticsView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import SwiftUI

struct GameStatisticsView: View {
    let game: Game
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.5)
            
            VStack {
                Text("Game Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List {
                    ForEach(game.players) { player in
                        PlayerGameStatsCard(player: player, game: game)
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
        .navigationTitle("Game Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlayerGameStatsCard: View {
    let player: Player
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(player.name)
                .font(.headline)
            
            let totalScore = game.roundHistory.flatMap { $0.scoreChanges }.filter { $0.playerName == player.name }.reduce(0) { $0 + $1.pointsAdded }
            let roundsPlayed = game.roundHistory.filter { $0.scoreChanges.contains(where: { $0.playerName == player.name }) }.count
            let roundsWon = game.roundHistory.filter { round in
                let winner = round.scoreChanges.min(by: { $0.pointsAdded < $1.pointsAdded })
                return winner?.playerName == player.name
            }.count
            let roundWinPercentage = roundsPlayed > 0 ? (Double(roundsWon) / Double(roundsPlayed)) * 100 : 0
            let averageScore = roundsPlayed > 0 ? Double(totalScore) / Double(roundsPlayed) : 0
            
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
    let alice = Player(name: "Alice")
    let bob = Player(name: "Bob")
    
    let game = Game(
        players: [alice, bob],
        targetScore: 200,
        roundHistory: [],
        winner: alice
    )
    
    return GameStatisticsView(game: game)
}
