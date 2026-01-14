//
//  WelcomeView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct WelcomeView: View {
    @Bindable var gameManager: GameManager
    @Environment(PlayerManager.self) private var playerManager
    @State private var targetScore: Int = 200
    @State private var newPlayerName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var penaltyEnabled: Bool = false
    @State private var penaltyInterval: PenaltyInterval = .fifty
    @State private var penaltyReduction: PenaltyReduction = .fixed(50)
    @State private var selectedGameMode: GameMode = .scoreLimitLoses
    @State private var selectedBoundaryCondition: BoundaryCondition = .cross
    
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
                        
                        Text("Game Counter")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Track your game scores for Yaniv, Uno and more")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // Game Presets
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Presets")
                            .font(.system(size: 20, weight: .semibold))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(GamePreset.allPresets) { preset in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            applyPreset(preset)
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: preset.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                            
                                            Text(preset.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 100, height: 90)
                                        .background(
                                            ZStack {
                                                if isPresetSelected(preset) {
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(LinearGradient(colors: [.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                } else {
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(.ultraThinMaterial)
                                                }
                                            }
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.white.opacity(0.1), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 4) // Slight padding for shadow/glow if needed
                        }
                    }
                    
                    // Target Score Selection
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
                                .keyboardType(.numberPad)
                                .focused($isTextFieldFocused)
                                .glassEffect(in: .rect(cornerRadius: 22))
                        }
                        
                        // Game Mode Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Win Condition")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Picker("Mode", selection: $selectedGameMode) {
                                ForEach(GameMode.allCases, id: \.self) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Picker("Condition", selection: $selectedBoundaryCondition) {
                                ForEach(BoundaryCondition.allCases, id: \.self) { condition in
                                    Text(condition.displayName).tag(condition)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 22))
                    
                    // Select Players Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Players")
                            .font(.system(size: 20, weight: .semibold))
                        
                        // Player list
                        if !playerManager.players.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(playerManager.players) { player in
                                    Button(action: {
                                        togglePlayerSelection(player)
                                    }) {
                                        HStack {
                                            Image(systemName: gameManager.players.contains(where: { $0.id == player.id }) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(gameManager.players.contains(where: { $0.id == player.id }) ? .orange : .secondary)
                                                .padding(.leading, 12)
                                            
                                            Text(player.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .padding(.vertical, 12)
                                            
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .glassEffect(in: .rect(cornerRadius: 22))
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        // Add player input
                        HStack(spacing: 12) {
                            TextField("Add new player", text: $newPlayerName)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16))
                                .padding(12)
                                .glassEffect(in: .rect(cornerRadius: 22))
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
                                    )
                            }
                            .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 22))
                    
                    // Penalty Settings
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
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 22))
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        if gameManager.players.count > 1 && targetScore > 0 {
                            Button(action: {
                                let settings = GameSettings(
                                    penaltyEnabled: penaltyEnabled,
                                    penaltyInterval: penaltyInterval,
                                    penaltyReduction: penaltyReduction,
                                    gameMode: selectedGameMode,
                                    boundaryCondition: selectedBoundaryCondition
                                )
                                gameManager.startNewGame(
                                    targetScore: targetScore,
                                    players: gameManager.players,
                                    settings: settings
                                )
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Start Game")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            .glassEffect(.regular.tint(.orange).interactive())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3)) {
            playerManager.addPlayer(trimmed)
        }
        
        newPlayerName = ""
        isTextFieldFocused = false
    }
    
    private func togglePlayerSelection(_ player: Player) {
        if let index = gameManager.players.firstIndex(where: { $0.id == player.id }) {
            gameManager.players.remove(at: index)
        } else {
            gameManager.players.append(player)
        }
    }
    
    private func isReductionSelected(_ current: PenaltyReduction, _ option: PenaltyReduction) -> Bool {
        return current == option
    }

    private func applyPreset(_ preset: GamePreset) {
        targetScore = preset.targetScore
        selectedGameMode = preset.gameMode
        selectedBoundaryCondition = preset.boundaryCondition
        penaltyEnabled = preset.penaltyEnabled
        penaltyInterval = preset.penaltyInterval
        penaltyReduction = preset.penaltyReduction
    }
    
    private func isPresetSelected(_ preset: GamePreset) -> Bool {
        return targetScore == preset.targetScore &&
               selectedGameMode == preset.gameMode &&
               selectedBoundaryCondition == preset.boundaryCondition &&
               penaltyEnabled == preset.penaltyEnabled &&
               (!penaltyEnabled || (penaltyInterval == preset.penaltyInterval && penaltyReduction == preset.penaltyReduction))
    }
}

#Preview {
    WelcomeView(gameManager: GameManager())
}

