//
//  MultiplayerLobbyView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

import SwiftUI
import MultipeerConnectivity

struct MultiplayerAuthView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showMultiPlayer: Bool
    
    var body: some View {
        ZStack {
            if (authManager.userIsLoaded) {
                MultiplayerLobbyView(showMultiPlayer: $showMultiPlayer)
            } else {
                VStack{
                    Text("Please log in to play multiplayer")
                        .rachaelsFontStyleMode(size: 20)
                    Button {
                        showMultiPlayer.toggle()
                    } label: {
                        Text("Close and Log in")
                            .rachaelsFontStyleMode(size: 20)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                    }
                }.rachaelsBackgroundColor()
            }
        }
    }
}

struct MultiplayerLobbyView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    
    @State var multiPeerManager: MultiPeerConnectionManager = MultiPeerConnectionManager(username: "Loading...") // initalize name to loading before the real username gets replaced
    @State var showMultiplayerGame: Bool = false
    @State var showInviteAlert: Bool = false
    
    @Binding var showMultiPlayer: Bool
    
    var body: some View {
        ZStack {
            if gameManager.multiplayerPlayers.count > 0 {
                if authManager.username == gameManager.multiplayerHost {
                    MultiplayerHostView(showMultiplayerGame: $showMultiplayerGame, showMultiPlayer: $showMultiPlayer)
                        .environment(multiPeerManager)
                } else {
                    MultiplayerPlayerInLobbyView(showMultiplayerGame: $showMultiplayerGame, showMultiPlayer: $showMultiPlayer)
                        .environment(multiPeerManager)
                }
            } else {
                VStack {
                    HStack {
                        Button {
                            showMultiPlayer = false
                            gameManager.gameState = .menu
                        } label: {
                            Image(systemName: "house")
                                .rachaelsFontStyleMode(size: 25)
                                .padding(7)
                                .background(Circle().fill(.ultraThinMaterial))
                                .shadow(radius: 5)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    Text("Wait for an Invite")
                        .rachaelsFontStyleMode(size: 30)
                    Spacer()
                    Text("OR")
                        .rachaelsFontStyleMode(size: 30)
                    Spacer()
                    Button {
                        gameManager.startLobbyMulti(curr_user: authManager.username!)
                    } label: {
                        Spacer()
                        
                        Text("Create Lobby")
                            .rachaelsFontStyleMode(size: 30)
                        
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                    Spacer()
                }.padding()
            }
        }
        .alert("Incoming Invitation", isPresented: $showInviteAlert) {
            Button("Accept") {
                multiPeerManager.invitationHandler!(true, multiPeerManager.session)
                multiPeerManager.recievedInvite = false
            }
            
            Button("Reject", role: .cancel) {
                multiPeerManager.invitationHandler!(false, multiPeerManager.session)
                multiPeerManager.recievedInvite = false
            }
        }
        .onChange(of: multiPeerManager.recievedInvite) { _, newValue in
            showInviteAlert = newValue
        }
        .rachaelsBackgroundColor()
        .onAppear {
            self.multiPeerManager = MultiPeerConnectionManager(username: authManager.username!)
            self.multiPeerManager.setup(game: gameManager)
            
            // start browsing and start advertising
            self.multiPeerManager.startBrowsing()
            self.multiPeerManager.startAdvertising()
            
        }
        .onDisappear {
            self.multiPeerManager.stopBrowsing()
            self.multiPeerManager.stopAdvertising()
        }
        .onChange(of: gameManager.gameState){ _, newState in
            if newState == .playingMulti {
                showMultiplayerGame = true
            }
        }
        
        //MARK: show the game
        if (showMultiplayerGame) {
            MultiplayerGameView(showMultiplayerGame: $showMultiplayerGame, showMultiplayerLobby: $showMultiPlayer)
                .environment(multiPeerManager)
        }
    }
}

struct MultiplayerHostView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    
    @Binding var showMultiplayerGame: Bool
    @Binding var showMultiPlayer: Bool
    
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    Button {
                        showMultiPlayer = false
                        gameManager.leaveLobbyMulti(curr_user: authManager.username!)
                        let leavingLobby = MPGameMove(action: .playerLeaving, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: leavingLobby)
                        gameManager.gameState = .menu
                        
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode(size: 25)
                            .padding(7)
                            .background(Circle().fill(.ultraThinMaterial))
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text("Multiplayer Lobby")
                        .rachaelsFontStyleMode(size: 30)
                }.padding()
                
                VStack {
                    Text("Available Players (Tap to Invite)")
                        .rachaelsFontStyleMode(size: 20)
                    ScrollView {
                        ForEach(multiPeerManager.availablePeers.indices, id: \.self){ id in
                            Button {
                                multiPeerManager.browserService.invitePeer(multiPeerManager.availablePeers[Int(id)], to: multiPeerManager.session, withContext: nil, timeout: 0) // invite the peer to this session.
                            } label : {
                                HStack {
                                    Spacer()
                                    Text("\(multiPeerManager.availablePeers[id].displayName)")
                                        .rachaelsFontStyleMode(size: 20)
                                    Spacer()
                                }.padding().background(Capsule().fill(.ultraThinMaterial))
                                    .padding()
                            }
                        }
                    }
                }
                
                HStack {
                    Text("Players in Lobby:")
                        .rachaelsFontStyleMode()
                    // little figures to represent other players
                    ForEach(gameManager.multiplayerPlayers.indices, id: \.self){ _ in
                        Image(systemName: "figure.wave")
                            .rachaelsFontStyleMode(size: 20, weight: .regular)
                            .padding(3)
                    }
                    Spacer()
                }.padding([.horizontal])
                
                HStack {
                    Text("Host: \(gameManager.multiplayerHost ?? "Unknown")") // unknown is just a fallback as it should never be unknown
                        .rachaelsFontStyleMode(size: 20)
                    Spacer()
                }.padding([.horizontal,.bottom])
                
                
                
                //MARK: Players in Lobby
                VStack {
                    Text("Players in Lobby:")
                        .rachaelsFontStyleMode(size: 18)
                    
                    ScrollView {
                        ForEach(gameManager.multiplayerPlayers.indices, id: \.self) { playerIndex in
                            HStack {
                                Text(gameManager.multiplayerPlayers[playerIndex])
                                    .rachaelsFontStyleMode()
                                Spacer()
                                
                                
                                Button {
                                    gameManager.hostRemovePlayer(username: gameManager.multiplayerPlayers[playerIndex])
                                } label: {
                                    Text("Click to kick")
                                        .rachaelsFontStyleMode(size: 12)
                                        .underline()
                                        .opacity(0.45)
                                }
                            } .padding()
                        }
                    }
                }
                
                //MARK: Start Game
                Button {
                    Task {
                        do {
                            try gameManager.hostStartGame(curr_user: authManager.username!)
                            let hostStartAction = MPGameMove(action: .start, hostPlayer: authManager.username!, multiplayerCards: gameManager.multiplayerCards, finishTimes: [:], players: gameManager.multiplayerPlayers)
                            multiPeerManager.send(gameMove: hostStartAction)
                            showMultiplayerGame = true
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Start Game")
                            .rachaelsFontStyleMode(size: 30)
                        Spacer()
                    }   .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                }.padding()
            }
        }
    }
}

struct MultiplayerPlayerInLobbyView: View { // for not the host
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    
    @Binding var showMultiplayerGame: Bool
    @Binding var showMultiPlayer: Bool
    
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    Button {
                        gameManager.leaveLobbyMulti(curr_user: authManager.username!)
                        let leavingLobby = MPGameMove(action: .playerLeaving, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: leavingLobby)
                        showMultiPlayer = false
                        gameManager.gameState = .menu
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode(size: 25)
                            .padding(7)
                            .background(Circle().fill(.ultraThinMaterial))
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text("Multiplayer Lobby")
                        .rachaelsFontStyleMode(size: 30)
                }.padding()
                
                HStack {
                    Text("Players:")
                        .rachaelsFontStyleMode()
                    // little figures to represent other players
                    ForEach(gameManager.multiplayerPlayers.indices, id: \.self){ _ in
                        Image(systemName: "figure.wave")
                            .rachaelsFontStyleMode(size: 20, weight: .regular)
                            .padding(3)
                    }
                    Spacer()
                }.padding([.horizontal])
                
                HStack {
                    Text("Host: \(gameManager.multiplayerHost ?? "Unknown")") // unknown is just a fallback as it should never be unknown
                        .rachaelsFontStyleMode(size: 20)
                    Spacer()
                }.padding([.horizontal,.bottom])
                
                
                
                //MARK: Players in Lobby
                VStack {
                    Text("Players in Lobby:")
                        .rachaelsFontStyleMode(size: 18)
                    
                    ScrollView {
                        ForEach(gameManager.multiplayerPlayers.indices, id: \.self) { playerIndex in
                            HStack {
                                Text("\(gameManager.multiplayerPlayers[playerIndex])")
                                    .rachaelsFontStyleMode()
                                Spacer()
                                
                            } .padding()
                        }
                    }
                }

            }
        }
            .rachaelsBackgroundColor()
    }
}

//#Preview {
//    MultiplayerLobbyView(showMultiPlayer: .constant(true))
//        .environment(NetworkManager())
//        .environment(AuthManager())
//}
