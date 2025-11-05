//
//  GameStatisticsView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import SwiftUI
import Charts

struct LineChartView: View {
    let game: Game
    
    var body: some View {
        Chart {
            ForEach(game.players) { player in
                let cumulativeScores = cumulativeScoresForPlayer(player)
                ForEach(Array(cumulativeScores.enumerated()), id: \.offset) { index, score in
                    LineMark(
                        x: .value("Round", index),
                        y: .value("Score", score)
                    )
                    .foregroundStyle(by: .value("Player", player.name))
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .padding()
        .frame(height: 300)
        .glassEffect(in: .rect(cornerRadius: 22))
        .padding(.horizontal)
    }
    
    private func cumulativeScoresForPlayer(_ player: Player) -> [Int] {
        var cumulativeScores: [Int] = [0] // Start with a score of 0
        var currentScore = 0
        for round in game.roundHistory {
            if let scoreChange = round.scoreChanges.first(where: { $0.playerName == player.name }) {
                currentScore += scoreChange.pointsAdded
            }
            cumulativeScores.append(currentScore)
        }
        return cumulativeScores
    }
}

struct GameStatisticsView: View {
    let game: Game
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.5)
            
            VStack {
                ScrollView {
                    VStack {
                        LineChartView(game: game)
                            .padding(.vertical, 4)
                        ForEach(game.players) { player in
                            PlayerGameStatsCard(player: player, game: game)
                                .padding(16)
                                .glassEffect(in: .rect(cornerRadius: 22))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                        }
                    }
                }
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
