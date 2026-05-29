//
//  GameViewModel.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/8/26.
//
import Foundation
import SwiftUI

enum GameState {
    case menu, startSingle, playingSingle, endedSingle, lobbyMulti, playingMulti, endedMulti
}

@Observable
class GameViewModel {
    var gameState : GameState = .menu
    var cards : [SpotItCard] = []
    
    // the default main card and default card are for so I can test before card generation ;)
    // these are for singleplayer only!!
    var mainCardIndex : Int = 0
    var currentCardIndex : Int = 1
    
    var gameStats: GameStats = .init()
    
    var gameIcons: [Int : String] = [:]
    
    var matchedCards: [SpotItCard] {
        cards.filter({$0.isMatched})
    }
    
    var cardsLeft: Int { // for single player view to see how many cards are left
        cards.count - matchedCards.count
    }
    
    var allMatched: Bool {
        matchedCards.count == cards.count // if all cards are matched the game will finish
    }
    
    // Tracking user Stats
    var elapsedTime: TimeInterval = 0
    var timerStartDate : Date?
    
    // end singleplayer vars (above)
    // begin multiplayer variables/constants (below)
    let max_multiplayers: Int = 8
    let min_multiplayers: Int = 2
    
    var multiplayerPlayers: [String] = []
    var multiplayerHost: String?
    var multiplayerCards: [String: [SpotItCard]] = ["main":[]]
    var current_player_index: Int = 0
    // main card will be accessed by the last card in the "main" dictionary
    var multiElapsedTime: TimeInterval = 0
    var multiplayerElapsedTimes: [String: TimeInterval] = [:]
    var multiTimerStartDate: Date?
    var finishedPlayers: Int {
        multiplayerElapsedTimes.count
    }
    var currMultiplayerDone: Bool {
        // once each player finishes their deck, the game ends and make sure there are players
        (finishedPlayers == multiplayerPlayers.count && multiplayerPlayers.count > 0)
    }
    
    init() {
        // generate the cards in init
        resetDefaultIcons()
        cards = generateCards()
        gameState = .menu
    }
    
    func resetDefaultIcons() -> Void {
        var defaultIcons: [Int : String] = [:]
        var iconNumber: Int = 0
        for icon in SpotItIcon.allCases {
            defaultIcons[iconNumber] = icon.rawValue
            iconNumber += 1
        }
        gameIcons = defaultIcons
    }
    
    //MARK: Card Generation
    func generateCards() -> [SpotItCard] {
        let generateThem = GenerateCards.init()
        
        return generateThem.generated_cards
    }
    
    func resetIsMatched() -> Void {
        for index in cards.indices {
            cards[index].isMatched = false
        }
    }
    
    func changeIcon(iconIndex: Int, newIcon: String) throws -> Void{
        if (!gameIcons.values.contains(newIcon)) {
            gameIcons[iconIndex] = newIcon
        }
        else {
            throw GameError.iconUnavailable
        }
    }
    
    //MARK: Singleplayer logic
    func startSinglePlayerGame() {
        // shuffle the deck
        gameState = .playingSingle
        
        // reset timer
        elapsedTime = 0
        timerStartDate = nil
        
        // reset cards and get first and second card to start game
        resetIsMatched()
        //TODO: actually shuffle the cards
        cards = cards.shuffled()
        mainCardIndex = 0
        currentCardIndex = 1
        cards[mainCardIndex].isMatched = true
        
        gameState = .startSingle
    }
    
    func finishSinglePlayerGame(username: String) async -> Void {
        if (gameState == .playingSingle && allMatched) {
            guard let timeStartDate = self.timerStartDate else { return }
            elapsedTime = Date().timeIntervalSince(timeStartDate)
            if (username == "Unknown User") {
                gameStats.addStat(username: username, time: Float(elapsedTime))
                gameStats.addUnsavedStat(username: username, time: Float(elapsedTime))
                gameStats.saveNotConnected()
            }
            gameState = .endedSingle
            
        }
    }
    
    func attemptMatch(selectedIcon : Int) -> Void {
        // matching from "current" card or main card
        if gameState == .startSingle {
            gameState = .playingSingle
            timerStartDate = Date()
        }
        if (cards[mainCardIndex].icons.contains(selectedIcon) && cards[currentCardIndex].icons.contains(selectedIcon)) {
            cards[currentCardIndex].isMatched = true
            mainCardIndex = currentCardIndex
            if (mainCardIndex + 1 < cards.count) { // check out of bounds
                currentCardIndex = mainCardIndex + 1
            }
            else {
                gameState = .endedSingle
            }
        }
    }
    
    //MARK: Timer updating Single
    func updateSingleTimer() {
        guard gameState == .playingSingle, let startDate = timerStartDate else { return }
        elapsedTime = Date().timeIntervalSince(startDate)
    }
    
//    //MARK: "cheat" button for singleplayer
//    func debugFinishGame() {
//        for index in cards.indices {
//            cards[index].isMatched = true
//        }
//    } // you can unncomment this and a button in single player view for easier testing.
    
    
    // MARK: Multiplayer logic
    func startLobbyMulti(curr_user: String) {
        gameState = .lobbyMulti
        multiplayerHost = curr_user
        multiplayerPlayers.append(curr_user)
    }
    
    func enterLobbyMulti(curr_user: String) {
        gameState = .lobbyMulti
        multiplayerPlayers.append(curr_user)
    }
    
    func recieveLobbyInfo(host: String, players: [String]) {
        multiplayerHost = host
        multiplayerPlayers = players
    }
    
    func recievePlayerLeaving(players: [String]) { // update player list when a player leaves the lobby or gets kicked by host
        multiplayerPlayers = players
        if !players.contains(multiplayerHost ?? "") {
            multiplayerHost = nil
            multiplayerPlayers = []
        }
    }
    
    func hostRemovePlayer(username: String) {
        multiplayerPlayers.removeAll(where: {$0 == username}) // remove the player the host wants to kick
    }
    
    func leaveLobbyMulti(curr_user: String) {
        guard gameState == .lobbyMulti || gameState == .endedMulti else { return }
        if multiplayerPlayers.contains(where: {$0 == curr_user} ) {
            multiplayerPlayers.removeAll(where: {$0 == curr_user})
        }
        if curr_user == multiplayerHost {
            multiplayerHost = nil
            multiplayerPlayers = []
            
        }
    }
    
    func hostStartGame(curr_user: String) throws {
        guard gameState == .lobbyMulti, multiplayerHost == curr_user else { return }
        if multiplayerPlayers.count < 2 {
            throw GameError.tooFewPlayers
        }
        else if multiplayerPlayers.count > 8 {
            throw GameError.tooManyPlayers
        }
        // reset game info
        multiElapsedTime = 0
        multiplayerElapsedTimes = [:]
        multiTimerStartDate = nil
        multiplayerCards = ["main":[]]
        
        
        // generate the decks for each player by splitting them up
        // each player gets 56/ # of players of the deck
        let cards_per_player: Int = (cards.count - 1) / multiplayerPlayers.count
        let num_extra_cards: Int = cards.count - (cards_per_player * multiplayerPlayers.count) // find out how many cards will be left over
        cards.shuffle() // shuffle the spot it cards so players don't always know first card
        for playerIndex in multiplayerPlayers.indices {
            multiplayerCards[multiplayerPlayers[playerIndex]] = Array(cards[cards_per_player*(playerIndex) ..< cards_per_player*(playerIndex+1)])
        }
        
        // give over the extra cards if there is more than one to players
        for i in 1..<num_extra_cards {
            // players will be a bit unlucky if they join first when theres extra cards, the last players will be spared
            let player_index = i % multiplayerPlayers.count // take remainder in case there are more extra cards than players
            multiplayerCards[multiplayerPlayers[player_index]]!.append(cards[(cards_per_player * multiplayerPlayers.count) + i])
        }
        // main card gets put in main deck
        multiplayerCards["main"] = [cards.last!] // the last card will be the main card
        
        
        gameState = .playingMulti
        multiTimerStartDate = Date()
    }
    
    func recieveStartGame(recievedMultiCards: [String:[SpotItCard]], players: [String]) {
        // reset values
        multiElapsedTime = 0
        multiplayerElapsedTimes = [:]
        
        multiplayerCards = recievedMultiCards
        multiplayerPlayers = players
        
        gameState = .playingMulti
        multiTimerStartDate = Date()
    }
    
    func multiplayerAttemptMatch(curr_user: String, selectedIcon: Int) -> Bool{
        // matching from "current" card
        var matched = false
        if (multiplayerCards[curr_user]!.first!.icons.contains(selectedIcon) && multiplayerCards["main"]!.last!.icons.contains(selectedIcon)) {
            multiplayerCards["main"]!.append(multiplayerCards[curr_user]![0]) // add first card from players deck to main
            multiplayerCards[curr_user]!.removeFirst() // remove the card we just added to main
            matched = true
        }
        return matched
    }
    
    func recieveMatch(recievedMultiCards: [String:[SpotItCard]]) {
        multiplayerCards = recievedMultiCards
    }
    
    func multiplayerPlayerFinishedCards(player: String) {
        guard gameState == .playingMulti else { return }
        if (multiplayerCards.keys.contains(player) && multiplayerCards[player]?.isEmpty == true) {
            // make sure the player is in the dict to avoid errors and then make sure the players deck is actually empty
            multiplayerElapsedTimes[player] = multiElapsedTime // save the time this player has done
        }
    }
    
    func recievePlayerFinish(recievedMultiCards: [String:[SpotItCard]], recievedMultiFinishTimes: [String: TimeInterval]) {
        multiplayerCards = recievedMultiCards
        multiplayerElapsedTimes = recievedMultiFinishTimes

    }
    
    func multiplayerEndGame() {
        guard gameState == .playingMulti else { return } // make sure a game is actually happening
        if finishedPlayers == multiplayerPlayers.count {
            gameState = .endedMulti
             
        }
    }
    
    
    //MARK: Multiplayer Timer
    func updateMultiplayerTimer() {
        guard gameState == .playingMulti, let startDate = multiTimerStartDate else { return }
        multiElapsedTime = Date().timeIntervalSince(startDate)
    }
    
    // MARK: Game Errors
    enum GameError: LocalizedError {
        case iconUnavailable
        case alreadyInLobby
        case tooFewPlayers
        case tooManyPlayers
        
        var errorDescription: String? {
            switch self {
            case .iconUnavailable:
                return "The Icon is Already in Use"
            case .alreadyInLobby:
                return "You are already in Lobby"
            case .tooFewPlayers:
                return "Not Enough Players, needed at least 2 for multiplayer"
            case .tooManyPlayers:
                return "Too Many Players, maximum number of players is 8"
            }
        }
    }
}
