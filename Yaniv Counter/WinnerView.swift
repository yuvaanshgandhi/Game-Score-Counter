//
//  WinnerView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct WinnerView: View {
    @Bindable var gameManager: GameManager
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.7)
            
            if showConfetti {
                ConfettiView()
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 10)
                
                // Winner name
                if let winner = gameManager.winner {
                    VStack(spacing: 12) {
                        Text("Winner!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .secondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(winner.name)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                        
                        Text("Final Score: \(winner.score)")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .scaleEffect(scale)
                }
                
                // Stats
                VStack(spacing: 16) {
                    StatRow(
                        icon: "number.circle.fill",
                        label: "Total Rounds",
                        value: "\(gameManager.currentRound)"
                    )
                    
                    StatRow(
                        icon: "person.2.fill",
                        label: "Players",
                        value: "\(gameManager.players.count)"
                    )
                    
                    StatRow(
                        icon: "target",
                        label: "Target Score",
                        value: "\(gameManager.targetScore)"
                    )
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Action button
                GradientButton(
                    "New Game",
                    icon: "arrow.counterclockwise",
                    colors: [.orange]
                ) {
                    gameManager.resetGame()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Animate trophy
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                rotation = 360
            }
            
            // Show confetti after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        GlassCard(padding: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    let manager = GameManager()
    manager.winner = Player(name: "Alice", score: 195)
    manager.currentRound = 12
    manager.players = [
        Player(name: "Alice", score: 195),
        Player(name: "Bob", score: 210, isEliminated: true)
    ]
    manager.targetScore = 200
    manager.gamePhase = .finished
    return WinnerView(gameManager: manager)
}

