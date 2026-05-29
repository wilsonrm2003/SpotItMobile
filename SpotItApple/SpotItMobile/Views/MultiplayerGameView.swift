//
//  MultiplayerGameView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//
import SwiftUI

struct MultiplayerGameView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showMultiplayerGame: Bool
    @Binding var showMultiplayerLobby: Bool
    
    private var formattedTime: String {
        let minutes = Int(gameManager.multiElapsedTime) / 60
        let seconds = Int(gameManager.multiElapsedTime) % 60
        let milliseconds = Int((gameManager.multiElapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    Text("Multiplayer")
                        .rachaelsFontStyleMode(size: 30)
                }.padding()
                
                HStack {
                    
                    // little dots to represent other players
                    ForEach(gameManager.multiplayerPlayers.indices, id: \.self) { _ in
                        Image(systemName: "figure.wave")
                            .rachaelsFontStyleMode(size: 20, weight: .regular)
                            .padding(3)
                    }
                }
                
                Spacer()
                
                //MARK: Card to Match
                MultiMainCardView()
                    .scaleEffect(0.5)
                    .frame(width: 150, height: 150)
                
                Spacer()
                
                //MARK: Card to Click
                MultiCardView()
                
                //MARK: Timer and cards left
                HStack {
                    //based off MindFlip's TimerView
                    TimelineView(.periodic(from: .now, by: 0.01)) { timeline in
                        HStack {
                            Image(systemName: "clock")
                                .rachaelsFontStyleMode(size: 20)
                            Text(formattedTime)
                                .rachaelsFontStyleMode(size: 20)
                            
                        }
                        .padding()
                        .frame(width: 180, height: 70)
                        .background(Capsule().fill(.ultraThinMaterial))
                        .onChange(of: timeline.date) { _, _ in
                            gameManager.updateMultiplayerTimer()
                        }
                    }.padding()
                    
                    
                    
                    // cards left
                    HStack{
                        Image(systemName: "progress.indicator")
                            .rachaelsFontStyleMode(size: 20)
                        
                        Text("\(gameManager.multiplayerCards[(authManager.username!)]?.count ?? -1)") // -1 for when there is an error getting the cards
                            .rachaelsFontStyleMode(size: 20)
                            
                    }
                    .padding()
                    .frame(width: 100, height: 70)
                    .background(Capsule().fill(.ultraThinMaterial))
                }
            }
            
            if (gameManager.gameState == .endedMulti) {
                MultiGameOver(showMultiplayerGame: $showMultiplayerGame, showMultiplayerLobby: $showMultiplayerLobby)
            }
        }.rachaelsBackgroundColor()
    }
}

//MARK: game over overlay
struct MultiGameOver : View {
    @Environment(GameViewModel.self) var gameManager
    @Environment(AuthManager.self) var authManager
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showMultiplayerGame: Bool
    @Binding var showMultiplayerLobby: Bool
    
    private func formatTime(_ seconds: Float) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let miliseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, secs, miliseconds)
    }
    
    private var sortedStats: [(key: String, value: TimeInterval)] {
        gameManager.multiplayerElapsedTimes.sorted { $0.value < $1.value }
    }
    
    var body: some View {
        VStack{
            VStack {
                
                HStack {
                    Image("marco")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                    
                    Text("Congradulations your group has completed the deck!!  ;)")
                        .rachaelsFontStyleMode(size: 15)
                        .padding([.vertical])
                }
                
                ScrollView {
                    ForEach(Array(sortedStats.indices), id: \.self) { index in
                        MultiLeaderboardRow(
                            rank: index + 1,
                            username: sortedStats[index].key,
                            time: Float(sortedStats[index].value),
                            formatTime: formatTime
                        ).padding(3)
                        
                    }
                }
                
                
                //MARK: Buttons
                HStack {
                    Button {
                        showMultiplayerGame = false
                        
                    } label: {
                        Text("Back to Lobby")
                            .rachaelsFontStyleMode()
                            .padding(8)
                            .background(Capsule().fill(.ultraThickMaterial))
                    }
                    
                    Button {
                        showMultiplayerGame = false
                        showMultiplayerLobby = false
                        gameManager.leaveLobbyMulti(curr_user: authManager.username!)
                        let leavingLobby = MPGameMove(action: .playerLeaving, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: leavingLobby)
                        gameManager.gameState = .menu
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode()
                            .padding(8)
                            .background(Capsule().fill(.ultraThickMaterial))
                    }
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
            .padding()
        }
    }
}

// MARK: multi Leaderboard row
struct MultiLeaderboardRow: View {
    @Environment(AuthManager.self) var authManager
    @Environment(\.colorScheme) var colorScheme
    
    let rank: Int
    let username: String
    let time: Float
    let formatTime: (Float) -> String
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rankEmoji)
                .rachaelsFontStyleMode()
                .frame(width: 20)
            
            // Player Name and Difficulty
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .rachaelsFontStyleMode(weight: .bold)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .rachaelsFontStyleMode(size: 15, weight: .regular)
                    
                    Text(formatTime(time))
                        .rachaelsFontStyleMode(weight: .bold)
                }
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rank <= 3 ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 4)
                )
                
        )
        .padding(.horizontal)
    }
}

//#Preview {
//    MultiplayerGameView()
//        .environment(NetworkManager())
//        .environment(AuthManager())
//}
