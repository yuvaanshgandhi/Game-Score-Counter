//
//  HistoryView.swift
//  Game Score Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct HistoryView: View {
    @Bindable var gameManager: GameManager
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.5)
            
            if gameManager.roundHistory.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "clock.badge.xmark")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No rounds yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("Start playing to see history")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Undo button
                        if gameManager.gamePhase == .playing && !gameManager.roundHistory.isEmpty {
                            Button(action: {
                                withAnimation {
                                    gameManager.undoLastRound()
                                }
                                
                                // Haptic feedback
                                HapticHelper.impact(.light)
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Undo Last Round")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background {
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        
                        // History list
                        ForEach(gameManager.roundHistory.reversed()) { round in
                            RoundHistoryCard(round: round)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .navigationTitle("Round History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if gameManager.gamePhase == .finished {                         
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: GameStatisticsView(game: Game(players: gameManager.players, targetScore: gameManager.targetScore, roundHistory: gameManager.roundHistory, winner: gameManager.winner))) {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
            }
        }
    }
}

struct RoundHistoryCard: View {
    let round: RoundHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Round \(round.roundNumber)")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Text(round.timestamp, style: .time)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(round.scoreChanges) { change in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(change.playerName)
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                if change.wasEliminated {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                                
                                Text("+\(change.pointsAdded)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(change.wasEliminated ? .red : .primary)
                            }
                        }
                        
                        // Show bonus reduction if applied
                        if let reduction = change.bonusReduction {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.orange)
                                Text("Bonus: -\(reduction)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.orange)
                            }
                            .padding(.leading, 4)
                        }
                    }
                }
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 22))
    }
}

#Preview {
    let manager = GameManager()
    manager.roundHistory = [
        RoundHistory(
            roundNumber: 1,
            scoreChanges: [
                PlayerScoreChange(playerId: UUID(), playerName: "Alice", pointsAdded: 15),
                PlayerScoreChange(playerId: UUID(), playerName: "Bob", pointsAdded: 20)
            ]
        ),
        RoundHistory(
            roundNumber: 2,
            scoreChanges: [
                PlayerScoreChange(playerId: UUID(), playerName: "Alice", pointsAdded: 25),
                PlayerScoreChange(playerId: UUID(), playerName: "Bob", pointsAdded: 10)
            ]
        )
    ]
    return HistoryView(gameManager: manager)
}

