import SwiftUI

public enum ScoreboardDestination {
    case history, statistics
}

struct ScoreboardView: View {
    @Bindable var gameManager: GameManager
    @State private var showAddRound = false
    @State private var showingEndGameConfirmation = false
    
    var body: some View {
        ZStack {
            LiquidGlassBackground(color: .orange, intensity: 0.6)
            
            VStack(spacing: 0) {
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
                        // Header
                        VStack(spacing: 8) {
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
                    }
                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Bottom Action Bar
                HStack {
                    Button(action: {
                        showAddRound = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("+ Round")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.tint(.orange).interactive())
                    .disabled(gameManager.getActivePlayers().isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .sheet(isPresented: $showAddRound) {
            AddRoundView(gameManager: gameManager)
        }
        .navigationDestination(for: ScoreboardDestination.self) { destination in
            switch destination {
            case .history:
                HistoryView(gameManager: gameManager)
            case .statistics:
                GameStatisticsView(game: Game(players: gameManager.players, targetScore: gameManager.targetScore, roundHistory: gameManager.roundHistory, winner: gameManager.winner))
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                // Header
                VStack {
                    Text("Round \(gameManager.currentRound)")
                        .font(.system(size: 24, weight: .bold))
                    Text("Max Points: \(gameManager.targetScore)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    NavigationLink(value: ScoreboardDestination.history) {
                        Image(systemName: "clock")
                    }
                    NavigationLink(value: ScoreboardDestination.statistics) {
                        Image(systemName: "chart.bar.xaxis")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        gameManager.pauseGame()
                    }) {
                        Image(systemName: "pause.circle")
                    }
                    Button(role: .destructive, action: {
                        showingEndGameConfirmation = true
                    }) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.red)
                    }
                    .alert("End Game?", isPresented: $showingEndGameConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("End Game", role: .destructive) {
                            gameManager.endGame()
                        }
                    } message: {
                        Text("The player with the lowest score will be declared the winner.")
                    }
                }
            }
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
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 22))
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
