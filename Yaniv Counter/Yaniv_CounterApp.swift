//
//  Yaniv_CounterApp.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-02.
//

import SwiftUI

@main
struct Yaniv_CounterApp: App {
    @State private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(gameManager: gameManager)
        }
    }
}
