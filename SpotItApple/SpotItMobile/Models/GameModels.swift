//
//  GameModels.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/28/26.
//
import Foundation

struct MPGameMove: Codable {
    enum Action: Int, Codable {
        case lobbyEnter, playerLeaving, start, match, playerFinish
    }
    
    let action: Action
    let hostPlayer: String?
    let multiplayerCards: [String:[SpotItCard]]?
    let finishTimes: [String: TimeInterval]?
    let players: [String]?
    
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
