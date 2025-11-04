//
//  PlayerManager.swift
//  Yaniv Counter
//
//  Created by Yuvaansh Gandhi on 2025-11-03.
//

import Foundation

@Observable
class PlayerManager {
    var players: [Player] = []
    
    private let playersKey = "yaniv_all_players"
    
    init() {
        loadPlayers()
    }
    
    func addPlayer(_ name: String) {
        let newPlayer = Player(name: name)
        players.append(newPlayer)
        savePlayers()
    }
    
    func deletePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayers()
    }
    
    private func savePlayers() {
        if let encoded = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(encoded, forKey: playersKey)
        }
    }
    
    private func loadPlayers() {
        if let data = UserDefaults.standard.data(forKey: playersKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            players = decoded
        }
    }
}
