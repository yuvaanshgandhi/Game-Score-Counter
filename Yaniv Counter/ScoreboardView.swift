//
//  ScoreboardView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct ScoreboardView: View {
    @Bindable var gameManager: GameManager
    @State private var showAddRound = false
    @State private var showHistory = false
    @State private var showStatistics = false
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.6)
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Round \(gameManager.currentRound)")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("Target: \(gameManager.targetScore)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                showStatistics = true
                            }) {
                                Label("Statistics", systemImage: "chart.bar.xaxis")
                            }
                            Button(action: {
                                gameManager.pauseGame()
                            }) {
                                Label("Pause and Go Home", systemImage: "pause.circle")
                            }
                            Button(role: .destructive, action: {
                                gameManager.endGame()
                            }) {
                                Label("End Game", systemImage: "flag.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Active players count
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                        Text("\(gameManager.getActivePlayers().count) active")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(.ultraThinMaterial)
                
                // Players List
                ScrollView {
                    VStack(spacing: 16) {
                        let roundWinnerId = gameManager.roundHistory.last?.scoreChanges.min(by: { $0.pointsAdded < $1.pointsAdded })?.playerId
                        let roundLoserId = gameManager.roundHistory.last?.scoreChanges.max(by: { $0.pointsAdded < $1.pointsAdded })?.playerId
                        
                        // Active Players
                        ForEach(gameManager.getActivePlayers().sorted(by: { $0.score < $1.score })) { player in
                            PlayerCard(player: player, targetScore: gameManager.targetScore, isRoundWinner: player.id == roundWinnerId, isRoundLoser: player.id == roundLoserId)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        // Eliminated Players
                        if !gameManager.getEliminatedPlayers().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Eliminated")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)
                                    .padding(.top, 8)
                                
                                ForEach(gameManager.getEliminatedPlayers().sorted(by: { $0.score < $1.score })) { player in
                                    PlayerCard(player: player, targetScore: gameManager.targetScore, isEliminated: true)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Bottom Action Bar
                HStack(spacing: 16) {
                    Button(action: {
                        showHistory = true
                    }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 18, weight: .semibold))
                            Text("History")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    GradientButton(
                        "+ Round",
                        icon: "plus.circle.fill"
                    ) {
                        showAddRound = true
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(gameManager.getActivePlayers().isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showAddRound) {
            AddRoundView(gameManager: gameManager)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(gameManager: gameManager, isPresentedFromScoreboard: true)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(gameHistory: gameManager.gameHistory)
        }
    }
}

struct PlayerCard: View {
    let player: Player
    let targetScore: Int
    var isEliminated: Bool = false
    var isRoundWinner: Bool = false
    var isRoundLoser: Bool = false
    
    var progress: Double {
        min(Double(player.score) / Double(targetScore + 1), 1.0)
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: isEliminated ? "xmark.circle.fill" : "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                isEliminated
                                    ? LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(player.name)
                                .font(.system(size: 20, weight: .semibold))
                                .strikethrough(isEliminated)
                            
                            if isEliminated {
                                Text("Eliminated")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
//                    Spacer()
                    
                    if isRoundWinner {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(.yellow)
                    }
                    
                    if isRoundLoser {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18))
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(player.score)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: isEliminated ? [.red, .orange] : [.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        if !isEliminated {
                            Text("\(targetScore + 1 - player.score) to eliminate")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if !isEliminated {
                    ProgressBar(progress: progress, color: .orange)
                }
            }
        }
        .opacity(isEliminated ? 0.6 : 1.0)
    }
}

#Preview {
    let manager = GameManager()
    manager.players = [
        Player(name: "Alice", score: 150),
        Player(name: "Bob", score: 180, isEliminated: true),
        Player(name: "Charlie", score: 120)
    ]
    manager.targetScore = 200
    manager.currentRound = 5
    manager.gamePhase = .playing
    return ScoreboardView(gameManager: manager)
}

