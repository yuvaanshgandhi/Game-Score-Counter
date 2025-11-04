//
//  WelcomeView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct WelcomeView: View {
    @Bindable var gameManager: GameManager
    @State private var targetScore: Int = 200
    @State private var newPlayerName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var penaltyEnabled: Bool = false
    @State private var penaltyInterval: PenaltyInterval = .fifty
    @State private var penaltyReduction: PenaltyReduction = .fixed(50)
    @State private var showGameHistory = false
    
    let presetScores = [100, 200, 500, 1000]
    let reductionOptions: [PenaltyReduction] = [.fixed(50), .fixed(100), .half]
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.8)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Yaniv Counter")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Track your game scores")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // Target Score Selection
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Target Score")
                                .font(.system(size: 20, weight: .semibold))
                            
                            // Preset scores
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(presetScores, id: \.self) { score in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            targetScore = score
                                        }
                                    }) {
                                        Text("\(score)")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(targetScore == score ? .white : .primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background {
                                                if targetScore == score {
                                                    LinearGradient(
                                                        colors: [.orange],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                } else {
                                                    Color.secondary.opacity(0.1)
                                                }
                                            }
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            // Custom score input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Custom")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                TextField("Enter score", value: $targetScore, format: .number)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(12)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(10)
                                    .keyboardType(.numberPad)
                                    .focused($isTextFieldFocused)
                            }
                        }
                    }
                    
                    // Add Players Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Players")
                                .font(.system(size: 20, weight: .semibold))
                            
                            // Add player input
                            HStack(spacing: 12) {
                                TextField("Player name", text: $newPlayerName)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 16))
                                    .padding(12)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(10)
                                    .focused($isTextFieldFocused)
                                    .onSubmit {
                                        addPlayer()
                                    }
                                
                                Button(action: addPlayer) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                                                        .foregroundStyle(
                                                                            LinearGradient(
                                                                                colors: [.orange],
                                                                                startPoint: .topLeading,
                                                                                endPoint: .bottomTrailing
                                                                            )
                                                                        )                                }
                                .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                            
                            // Player list
                            if !gameManager.players.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(gameManager.players) { player in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                            
                                            Text(player.name)
                                                .font(.system(size: 16, weight: .medium))
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    gameManager.removePlayer(player)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.red.opacity(0.6))
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.secondary.opacity(0.05))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    // Penalty Settings
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Score Bonus")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Spacer()
                                
                                Toggle("", isOn: $penaltyEnabled)
                                    .labelsHidden()
                            }
                            
                            if penaltyEnabled {
                                VStack(spacing: 16) {
                                    // Interval Selection
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Bonus Interval")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        HStack(spacing: 12) {
                                            ForEach(PenaltyInterval.allCases, id: \.self) { interval in
                                                Button(action: {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        penaltyInterval = interval
                                                    }
                                                }) {
                                                    Text("Every \(interval.displayName)")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(penaltyInterval == interval ? .white : .primary)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 10)
                                                        .background {
                                                            if penaltyInterval == interval {
                                                                LinearGradient(
                                                                    colors: [.orange],
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                            } else {
                                                                Color.secondary.opacity(0.1)
                                                            }
                                                        }
                                                        .cornerRadius(8)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    
                                    // Reduction Selection
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Points Reduction")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        HStack(spacing: 12) {
                                            ForEach(Array(reductionOptions.enumerated()), id: \.offset) { index, reduction in
                                                let isSelected = isReductionSelected(penaltyReduction, reduction)
                                                Button(action: {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        penaltyReduction = reduction
                                                    }
                                                }) {
                                                    Text(reduction.displayName)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(isSelected ? .white : .primary)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 10)
                                                        .background {
                                                            if isSelected {
                                                                LinearGradient(
                                                                    colors: [.orange],
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                            } else {
                                                                Color.secondary.opacity(0.1)
                                                            }
                                                        }
                                                        .cornerRadius(8)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    
                                    // Explanation
                                    HStack(spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.blue)
                                        Text("Reduces score when player reaches interval thresholds")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.top, 4)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        if !gameManager.players.isEmpty && targetScore > 0 {
                            GradientButton(
                                "Start Game",
                                icon: "play.fill",
                                colors: [.orange]
                            ) {
                                let settings = GameSettings(
                                    penaltyEnabled: penaltyEnabled,
                                    penaltyInterval: penaltyInterval,
                                    penaltyReduction: penaltyReduction
                                )
                                gameManager.startNewGame(
                                    targetScore: targetScore,
                                    playerNames: gameManager.players.map { $0.name },
                                    settings: settings
                                )
                            }
                        }
                        
                        if !gameManager.gameHistory.isEmpty {
                            Button(action: {
                                showGameHistory = true
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
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .sheet(isPresented: $showGameHistory) {
                GameHistoryView(gameManager: gameManager)
            }
        }
    }
    
    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3)) {
            gameManager.addPlayer(trimmed)
        }
        
        newPlayerName = ""
        isTextFieldFocused = false
    }
    
    private func isReductionSelected(_ current: PenaltyReduction, _ option: PenaltyReduction) -> Bool {
        return current == option
    }
}

#Preview {
    WelcomeView(gameManager: GameManager())
}

