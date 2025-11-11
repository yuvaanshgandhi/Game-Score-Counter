//
//  ContentView.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

struct ContentView: View {
    @Bindable var gameManager: GameManager
    
    var body: some View {
        Group {
            switch gameManager.gamePhase {
            case .setup, .paused:
                setupTabView
            case .playing, .finished:
                playingTabView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.gamePhase)
    }
    
    private var setupTabView: some View {
        TabView {
            WelcomeView(gameManager: gameManager)
                .tabItem {
                    Label("New Game", systemImage: "gamecontroller")
                }
                .id("setup")
            
            OngoingGamesView(gameManager: gameManager)
                .tabItem {
                    Label("Ongoing", systemImage: "pause.circle")
                }
            
            GameHistoryView(gameManager: gameManager)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            StatisticsView(gameHistory: gameManager.gameHistory)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
        }
    }
    
    private var playingTabView: some View {
        TabView {
            Group {
                switch gameManager.gamePhase {
                case .playing:
                    ScoreboardView(gameManager: gameManager)
                        .id("playing")
                case .finished:
                    WinnerView(gameManager: gameManager)
                        .id("finished")
                default:
                    // Should not happen, but as a fallback
                    WelcomeView(gameManager: gameManager)
                        .id("fallback")
                }
            }
            .tabItem {
                Label("Game", systemImage: "gamecontroller")
            }
            
            HistoryView(gameManager: gameManager)
                .tabItem {
                    Label("Round History", systemImage: "clock")
                }
            
            GameStatisticsView(game: Game(players: gameManager.players, targetScore: gameManager.targetScore, roundHistory: gameManager.roundHistory, winner: gameManager.winner))
                .tabItem {
                    Label("Game Statistics", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

#Preview {
    ContentView(gameManager: GameManager())
}
