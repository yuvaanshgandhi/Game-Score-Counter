//
//  AddRoundView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct AddRoundView: View {
    @Bindable var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var scoreInputs: [UUID: String] = [:]
    @FocusState private var focusedPlayerId: UUID?
    
    var activePlayers: [Player] {
        gameManager.getActivePlayers()
    }
    
    var canSubmit: Bool {
        activePlayers.allSatisfy { player in
            let input = scoreInputs[player.id] ?? ""
            return !input.isEmpty
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(color: .orange, intensity: 0.5)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Add Round \(gameManager.currentRound + 1)")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.top, 20)
                        
                        Text("Enter points for each player")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 16) {
                            ForEach(activePlayers) { player in
                                ScoreInputCard(
                                    player: player,
                                    scoreText: Binding(
                                        get: { scoreInputs[player.id] ?? "" },
                                        set: { scoreInputs[player.id] = $0 }
                                    ),
                                    isFocused: focusedPlayerId == player.id
                                )
                                .focused($focusedPlayerId, equals: player.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 20)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        submitRound()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSubmit)
                }
            }
        }
        .onAppear {
            // Pre-fill with empty strings
            for player in activePlayers {
                if scoreInputs[player.id] == nil {
                    scoreInputs[player.id] = ""
                }
            }
        }
    }
    
    private func submitRound() {
        var scoreChanges: [UUID: Int] = [:]
        
        for player in activePlayers {
            let input = scoreInputs[player.id] ?? ""
            if let score = Int(input) {
                scoreChanges[player.id] = score
            }
        }
        
        guard !scoreChanges.isEmpty else { return }
        
        // Haptic feedback
        HapticHelper.impact(.medium)
        
        gameManager.addRound(scoreChanges: scoreChanges)
        dismiss()
    }
}

struct ScoreInputCard: View {
    let player: Player
    @Binding var scoreText: String
    let isFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Current: \(player.score)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            TextField("0", text: $scoreText)
                .textFieldStyle(.plain)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .frame(width: 80)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFocused ? Color.blue.opacity(0.15) : Color.secondary.opacity(0.1))
                }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 22))
    }
}

#Preview {
    let manager = GameManager()
    manager.players = [
        Player(name: "Alice", score: 150),
        Player(name: "Bob", score: 120),
        Player(name: "Charlie", score: 180)
    ]
    manager.targetScore = 200
    manager.gamePhase = .playing
    return AddRoundView(gameManager: manager)
}

