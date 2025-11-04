//
//  GameHistoryView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
    }
}

struct GameHistoryView: View {
    @Bindable var gameManager: GameManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(color: .orange, intensity: 0.5)
                
                if gameManager.gameHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No game history")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("Completed games will appear here.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                } else {
                    List {
                        ForEach(gameManager.gameHistory.reversed()) { game in
                            NavigationLink(destination: HistoryView(gameManager: createGameManager(for: game))) {
                                GameHistoryCell(game: game)
                            }
                            .modifier(GlassCardModifier())
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteGame)
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
//                    .padding(16)
                }
            }
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: StatisticsView(gameHistory: gameManager.gameHistory)) {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
            }
        }
    }
    
    private func createGameManager(for game: Game) -> GameManager {
        let gameManager = GameManager()
        gameManager.players = game.players
        gameManager.targetScore = game.targetScore
        gameManager.roundHistory = game.roundHistory
        gameManager.winner = game.winner
        gameManager.gamePhase = .finished
        return gameManager
    }
    
    private func deleteGame(at offsets: IndexSet) {
        // The List shows `gameHistory.reversed()`, so `offsets` refer to the reversed order.
        // Map each offset back to the original index in `gameHistory`.
        let count = gameManager.gameHistory.count
        let originalIndices = offsets.map { count - 1 - $0 }.sorted(by: >)
        for index in originalIndices {
            let game = gameManager.gameHistory[index]
            gameManager.deleteGame(game)
        }
    }
}

struct GameHistoryCell: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(game.date, style: .date)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                if let winner = game.winner {
                    Text("Winner: \(winner.name)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Final Scores")
                    .font(.system(size: 14, weight: .bold))
                
                ForEach(game.players.sorted(by: { $0.score < $1.score })) { player in
                    HStack {
                        Text(player.name)
                            .font(.system(size: 14))
                        Spacer()
                        Text("\(player.score)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(player.isEliminated ? .red : .primary)
                    }
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Players")
                        .font(.system(size: 14, weight: .bold))
                    Text(game.players.map { $0.name }.joined(separator: ", "))
                        .font(.system(size: 14))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Rounds")
                        .font(.system(size: 14, weight: .bold))
                    Text("\(game.roundHistory.count)")
                        .font(.system(size: 14))
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
            roundHistory: [],
            winner: Player(name: "Alice")
        )
    ]
    return GameHistoryView(gameManager: manager)
}
