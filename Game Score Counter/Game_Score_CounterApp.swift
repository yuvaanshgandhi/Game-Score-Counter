//
//  Game_Score_CounterApp.swift
//  Game Score Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

@main
struct Game_Score_CounterApp: App {
    @State private var gameManager = GameManager()
    @State private var playerManager = PlayerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameManager: gameManager)
                .environment(playerManager)
        }
    }
}
