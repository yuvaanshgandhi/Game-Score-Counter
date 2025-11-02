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
            case .setup:
                WelcomeView(gameManager: gameManager)
                    .id("setup")
            case .playing:
                ScoreboardView(gameManager: gameManager)
                    .id("playing")
            case .finished:
                WinnerView(gameManager: gameManager)
                    .id("finished")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.gamePhase)
    }
}

#Preview {
    ContentView(gameManager: GameManager())
}
