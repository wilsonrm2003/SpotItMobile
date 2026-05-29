//
//  MainView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

import SwiftUI

struct MainView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @State var showSinglePlayer: Bool = false
    @State var showMultiPlayer: Bool = false
    @State var showLeaderboard: Bool = false
    @State var showAccount: Bool = false
    
    var body: some View {
        ZStack {
            MainMenuView(showSinglePlayer: $showSinglePlayer, showMultiPlayer: $showMultiPlayer, showLeaderboard: $showLeaderboard, showAccount: $showAccount)
            
            if (showSinglePlayer) {
                SingleplayerGameView(showSingleplayer: $showSinglePlayer, showLeaderboard: $showLeaderboard)
            }
            
            if (showMultiPlayer) {
                MultiplayerAuthView(showMultiPlayer: $showMultiPlayer)
            }
            
            if (showLeaderboard) {
                LeaderboardView(showLeaderboard: $showLeaderboard)
            }
            
            if (showAccount) {
                UserLoggedCheckView(showAccount: $showAccount)
            }
        }
    }
}

struct MainMenuView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSinglePlayer: Bool
    @Binding var showMultiPlayer: Bool
    @Binding var showLeaderboard: Bool
    @Binding var showAccount: Bool
    var body: some View {
        //MARK: Main menu
        VStack{
            Spacer()
            
            Text("Spot it! Mobile")
                .rachaelsFontStyleMode(size: 40)
            Spacer()
            
            Button {
                showSinglePlayer = true
                gameManager.startSinglePlayerGame()
            } label: {
                Text("Singleplayer")
                    .rachaelsFontStyleMode(size: 30, weight: .bold)
                    .padding()
                    .background(Capsule().fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
            }
            .padding()
            
            Button {
                showMultiPlayer = true
            } label: {
                Text("Multiplayer")
                    .rachaelsFontStyleMode(size: 30, weight: .bold)
                    .padding()
                    .background(Capsule().fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
            }
            
            Spacer()
            
            HStack {
                Button {
                    showLeaderboard = true
                } label: {
                    Image(systemName: "medal.fill")
                        .rachaelsFontStyleMode(size: 40, weight: .bold)
                        .frame(width: 80, height: 80)
                        .background(Circle().fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
                }.padding()
                
                Spacer()
                
                Button {
                    showAccount = true
                } label: {
                    Image(systemName: "person.fill.questionmark")
                        .rachaelsFontStyleMode(size: 40, weight: .bold)
                        .frame(width: 80, height: 80)
                        .background(Circle().fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
                }
            }.padding()
        }
        .rachaelsBackgroundColor()
        .onChange(of: authManager.userIsLoaded) { _, _ in
            if (authManager.userIsLoaded) {
                Task {
                    do {
                        gameManager.gameIcons = try await networkManager.getUserIcons()
                    } catch {}
                }
                
                for stat in gameManager.gameStats.unsavedStats.filter({$0.username == authManager.username}) {
                    Task {
                        do {
                            let _ = try await networkManager.storeLeaderboardStat(time: stat.time)
                            gameManager.gameStats.networkStats = try await networkManager.getLeaderboard()
                            gameManager.gameStats.unsavedStats.removeAll(where: { $0.username == authManager.username}) // clear the current user that has been logged in since the user is now logged in ;)
                            gameManager.gameStats.saveNotConnected()
                        } catch {}
                    }
                }
                for stat in gameManager.gameStats.localStats.filter({ $0.username == "Unknown User"}) {
                    Task
                    {
                        do {
                            let _ = try await networkManager.storeLeaderboardStat(time: stat.time)
                            gameManager.gameStats.networkStats = try await networkManager.getLeaderboard()
                            gameManager.gameStats.localStats.removeAll(where: { $0.username == "Unknown User"}) // clear the unknown users since the user is now logged in ;)
                        } catch {}
                    }
                }
            } else {
                // means the user logged out so we want the default icons now
                gameManager.resetDefaultIcons() // reset the game icons
            }
        }
        .onChange(of: showLeaderboard) { _,_ in
            if (showLeaderboard) {
                Task {
                    do {
                        gameManager.gameStats.networkStats = try await networkManager.getLeaderboard() // get the leaderboard from network manager
                        gameManager.gameStats.save()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
#Preview {
    MainView()
        .environment(NetworkManager())
        .environment(AuthManager())
        .environment(GameViewModel())
}
