import SwiftUI

struct OngoingGamesView: View {
    @Bindable var gameManager: GameManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(color: .orange, intensity: 0.5)
                
                if gameManager.ongoingGames.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(gameManager.ongoingGames.sorted(by: { $0.date > $1.date })) { game in
                                row(for: game)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.25), value: gameManager.ongoingGames)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Ongoing Games")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Row
extension OngoingGamesView {
    @ViewBuilder
    func row(for game: Game) -> some View {
        Button(action: {
            withAnimation {
                gameManager.loadGame(game: game)
            }
        }) {
            HStack {
                Text("#\(gameManager.indexOf(game: game))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(game.players.count) Players")
                        .font(.system(size: 16, weight: .medium))
                    Text("Target: \(game.targetScore)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(game.players.map { $0.name }.joined(separator: ", "))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("Round \(game.roundHistory.count)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .glassEffect(in: .rect(cornerRadius: 22))
    }
}

// MARK: - Empty State
extension OngoingGamesView {
    var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No ongoing games")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text("Paused games will appear here.")
                .font(.system(size: 16))
                .foregroundColor(.secondary.opacity(0.8))
        }
    }
}

// MARK: - Helpers
extension GameManager {
    func indexOf(game: Game) -> Int {
        let sorted = ongoingGames.sorted(by: { $0.date > $1.date })
        return (sorted.firstIndex(where: { $0.id == game.id }) ?? 0) + 1
    }
}
