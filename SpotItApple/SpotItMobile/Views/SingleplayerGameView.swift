//
//  SingleplayerGameView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//
import SwiftUI

struct SingleplayerGameView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSingleplayer: Bool
    @Binding var showLeaderboard: Bool
    
    @State var gameEnded: Bool = false
    @State var statAdded: StatEntry?
    @State var serverError: Bool = false
    
    private var formattedTime: String {
        let minutes = Int(gameManager.elapsedTime) / 60
        let seconds = Int(gameManager.elapsedTime) % 60
        let milliseconds = Int((gameManager.elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var body: some View {
        //var trackGameEnded = gameManager.finishSinglePlayerGame(username: authManager.username ?? "Unknown User")
        ZStack{
            VStack {
                HStack {
                    Button {
                        showSingleplayer = false
                        gameManager.gameState = .menu
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode(size: 25)
                            .padding(7)
                            .background(Circle().fill(.ultraThinMaterial))
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text("Singleplayer")
                        .rachaelsFontStyleMode(size: 30)
                    
                    Spacer()
                    
                }.padding()
                
                Spacer()
                //MARK: Card to Match
                MainCardView()
                    .scaleEffect(0.5)
                    .frame(width: 150, height: 150)
                Spacer()
                
                //MARK: Card to Click
                CardView()
                
                Spacer()
                
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
                            gameManager.updateSingleTimer()
                        }
                    }.padding()
                    
                    
                    
                    // cards left
                    HStack{
                        Image(systemName: "progress.indicator")
                            .rachaelsFontStyleMode(size: 20)
                        
                        Text(String(gameManager.cardsLeft))
                            .rachaelsFontStyleMode(size: 20)
                            
                    }
                    .padding()
                    .frame(width: 100, height: 70)
                    .background(Capsule().fill(.ultraThinMaterial))
                }
                
//                //MARK: - Cheat Button
//                Button("Finish") {
//                    gameManager.debugFinishGame()
//                } // you can uncomment this and a function in GameViewModel for easier debugging.
                
            }
            .onChange(of: gameManager.allMatched) { _, matched in
                if (matched) {
                    Task {
                        await gameManager.finishSinglePlayerGame(username: authManager.username ?? "Unknown User")
                        if authManager.userIsLoaded {
                            do {
                                statAdded = try await networkManager.storeLeaderboardStat(time: Float(gameManager.elapsedTime))
                                gameManager.gameStats.networkStats = try await networkManager.getLeaderboard()
                                gameManager.gameStats.save()
                            } catch {
                                // do nothing because want to fall back to the last saved network
                                serverError = true
                                if (authManager.username != nil) {
                                    gameManager.gameStats.addUnsavedStat(username: authManager.username ?? "Unknown User", time: Float(gameManager.elapsedTime))
                                    gameManager.gameStats.saveNotConnected()
                                }
                                print(error)
                            }
                        }
                    }
                }
                
            }
            
            if gameManager.allMatched {
                SingleGameOver(statAdded: statAdded, serverError: serverError, showSingleplayer: $showSingleplayer, showLeaderboard: $showLeaderboard)
                
            }
        }
            .rachaelsBackgroundColor()
        
    }
}


//MARK: game over overlay
struct SingleGameOver : View {
    @Environment(GameViewModel.self) var gameManager
    @Environment(AuthManager.self) var authManager
    
    let statAdded : StatEntry?
    let serverError: Bool
    
    @Binding var showSingleplayer: Bool
    @Binding var showLeaderboard: Bool
    
    private var formattedTime: String {
        let minutes = Int(gameManager.elapsedTime) / 60
        let seconds = Int(gameManager.elapsedTime) % 60
        let milliseconds = Int((gameManager.elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private var getCurrentTimeRank: Int {
        let leaderboardStats = Array(gameManager.gameStats.gameStats).sorted { $0.time < $1.time }
        let currentTimeRank = (leaderboardStats.firstIndex(where: { $0.username == authManager.username && $0.time == statAdded?.time }) ?? -1) + 1
        return currentTimeRank
    }
    
    private var getPlayersHighestRank: Int {
        let leaderboardStats = Array(gameManager.gameStats.gameStats).sorted { $0.time < $1.time }
        let highestRank = (leaderboardStats.firstIndex(where: {
            $0.username == authManager.username
        }) ?? -1) + 1
        return highestRank
    }
    
    
    var body: some View {
        VStack{
            VStack {
                Text("Congrats You Have completed the deck!!  ;)")
                    .rachaelsFontStyleMode(size: 15)
                    .padding([.vertical])
                
                Image("marco")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                if (Int(gameManager.elapsedTime) < (5 * 60)) {
                    // less than 5 minutes you get a special message
                    Text("Marco Loves You <3")
                        .rachaelsFontStyleMode()
                        .padding()
                }
                
                
                
                // Your Time
                HStack {
                    Text("Time to Complete:")
                        .rachaelsFontStyleMode()
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .rachaelsFontStyleMode()
                }.padding()
                
                Text(authManager.userIsLoaded ? "Your Score will appear on the Leaderboard!" : "Log in to see Yourself on the Leaderboard!")
                    .rachaelsFontStyleMode(size: 12)
                    .padding()
                
                if (authManager.userIsLoaded) {
                    if (statAdded != nil) {
                        if (getCurrentTimeRank != 0) {
                            Text("Your Time's Leaderboard Rank is \(getCurrentTimeRank) place")
                                .rachaelsFontStyleMode(size: 12)
                        }
                        if (getPlayersHighestRank != 0) {
                            Text("Your Highest Rank on the Leaderboard is \(getPlayersHighestRank) place")
                                .rachaelsFontStyleMode(size: 12)
                        }
                    }
                    else {
                        if (!serverError) {
                            Text("Calculating Your Rank...")
                                .rachaelsFontStyleMode(size: 12)
                        }
                        else {
                            Text("Could Not connect to Network, Scores will be stored for later.")
                                .rachaelsFontStyleMode(size: 12)
                        }
                    }
                    
                }
                
                //MARK: Buttons
                HStack {
                    Button {
                        gameManager.startSinglePlayerGame()
                    } label: {
                        Text("Play Again")
                            .rachaelsFontStyleMode()
                            .padding(8)
                            .background(Capsule().fill(.ultraThickMaterial))
                    }
                    
                    Button {
                        showSingleplayer = false
                        gameManager.gameState = .menu
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode()
                            .padding(8)
                            .background(Capsule().fill(.ultraThickMaterial))
                    }
                    
                    Button {
                        showSingleplayer = false
                        showLeaderboard = true
                        gameManager.gameState = .menu
                    } label: {
                        Image(systemName: "medal.fill")
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

//#Preview {
//    let vm = GameViewModel()
//    return SingleplayerGameView(showSingleplayer: .constant(true), showLeaderboard: .constant(false))
//        .environment(vm)
//        .environment(NetworkManager())
//        .environment(AuthManager())
//}
