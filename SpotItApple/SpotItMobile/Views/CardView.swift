//
//  CardView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/8/26.
//
import SwiftUI

// MARK: Cards for Singleplayer
struct CardView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    var radius: CGFloat = 100 // control distance from center
    
    private var startAngle: Angle {
        .degrees(22)
    }
    
    private var endAngle: Angle {
        .degrees(startAngle.degrees + 360.0)
    }
    
    private var deltaAngle: Angle {
        .degrees((360.0) / Double(SpotItCard.numberOfIcons-1)) // number of icons will be 8 but in case we increase
    }
    
    var body: some View {
        let card = gameManager.cards[gameManager.currentCardIndex]
            ZStack {
                Circle()
                    .fill(Color.rachaelsBlue)
                    .frame(width: 350, height: 350)
                    .shadow(radius: 20)
                
                Button {
                    gameManager.attemptMatch(selectedIcon: card.icons[0])
                } label: {
                    let firstIconIndex = card.icons[0]
                    Text(gameManager.gameIcons[firstIconIndex] ?? "uhoh")
                        .rachaelsFontStyleMode(size: 50)
                        
                }
                .position(x: 175.0, y: 175.0)
                
                ForEach(1..<(card.icons.count), id: \.self) { index in
                    let iconIndex = card.icons[index]
                    let angle = startAngle + deltaAngle * Double(index)
                    let xPos = 175.0 + cos(angle.radians) * radius
                    let yPos = 175.0 + sin(angle.radians) * radius
                    
                    Button{
                        gameManager.attemptMatch(selectedIcon: iconIndex)
                    } label:{
                        Text( gameManager.gameIcons[iconIndex] ?? "\(iconIndex)")
                            .rachaelsFontStyleMode(size: 50)
                            .rotationEffect(angle)
                    }
                    .position(x: xPos, y: yPos)
                }
                
            }
            .frame(width: 350, height: 350)
    }
}

struct MainCardView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    var radius: CGFloat = 100 // control distance from center
    
    private var startAngle: Angle {
        .degrees(22)
    }
    
    private var endAngle: Angle {
        .degrees(startAngle.degrees + 360.0)
    }
    
    private var deltaAngle: Angle {
        .degrees((360.0) / Double(SpotItCard.numberOfIcons-1)) // number of icons will be 8 but in case we increase
    }
    
    var body: some View {
        let mainCard = gameManager.cards[gameManager.mainCardIndex]
        ZStack {
            Circle()
                .fill(Color.rachaelsBlue)
                .frame(width: 350, height: 350)
                .shadow(radius: 20)
            
            Button {
                gameManager.attemptMatch(selectedIcon: mainCard.icons[0])
            } label: {
                let firstIconIndex = mainCard.icons[0]
                Text(gameManager.gameIcons[firstIconIndex] ?? "uhoh")
                    .rachaelsFontStyleMode(size: 50)
                    
            }
            .position(x: 175.0, y: 175.0)
            
            ForEach(1..<(mainCard.icons.count), id: \.self) { index in
                let iconIndex = mainCard.icons[index]
                let angle = startAngle + deltaAngle * Double(index)
                let xPos = 175.0 + cos(angle.radians) * radius
                let yPos = 175.0 + sin(angle.radians) * radius
                
                Button{
                    gameManager.attemptMatch(selectedIcon: iconIndex)
                } label:{
                    Text( gameManager.gameIcons[iconIndex] ?? "\(iconIndex)")
                        .rachaelsFontStyleMode(size: 50)
                        .rotationEffect(angle)
                }
                .position(x: xPos, y: yPos)
            }
            
        }
        .frame(width: 350, height: 350)
    }
    
}

#Preview {
    let gameManager = GameViewModel()
    ZStack{
        VStack {
            Spacer()
            //MARK: Card to Match
            MainCardView()
                .environment(NetworkManager())
                .environment(AuthManager())
                .environment(gameManager)
                .scaleEffect(0.5)
                .frame(width: 150, height: 150)
            Spacer()
            CardView()
                .environment(NetworkManager())
                .environment(AuthManager())
                .environment(gameManager)
            Spacer()
        }
    }
    .rachaelsBackgroundColor()
}


//MARK: Multiplayer Card Views
struct MultiCardView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    
    var radius: CGFloat = 100 // control distance from center
    
    private var startAngle: Angle {
        .degrees(22)
    }
    
    private var endAngle: Angle {
        .degrees(startAngle.degrees + 360.0)
    }
    
    private var deltaAngle: Angle {
        .degrees((360.0) / Double(SpotItCard.numberOfIcons-1)) // number of icons will be 8 but in case we increase
    }
    
    private var playerFinishTime: String {
        let minutes = Int(gameManager.multiplayerElapsedTimes[authManager.username!] ?? 0.0) / 60
        let seconds = Int(gameManager.multiplayerElapsedTimes[authManager.username!] ?? 0.0) % 60
        let milliseconds = Int(((gameManager.multiplayerElapsedTimes[authManager.username!] ?? 0.0).truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var body: some View {
        guard let card = gameManager.multiplayerCards[authManager.username!]!.first else { // get the first card from the players deck
            return AnyView(
                ZStack {
                    Circle()
                        .fill(Color.rachaelsBlue)
                        .frame(width: 350, height: 350)
                        .shadow(radius: 20)
                    
                    VStack {
                        Text("You Finished Your Deck!")
                            .rachaelsFontStyleMode()
                        
                        Text(playerFinishTime)
                            .rachaelsFontStyleMode()
                        
                        Text("Waiting for others to finish...")
                            .rachaelsFontStyleMode()
                    }
                }
            )
        }
        return AnyView(
            ZStack {
                Circle()
                    .fill(Color.rachaelsBlue)
                    .frame(width: 350, height: 350)
                    .shadow(radius: 20)
                
                Button {
                    let matchResult = gameManager.multiplayerAttemptMatch(curr_user: authManager.username!, selectedIcon: card.icons[0])
                    if matchResult == true {
                        let matchMove = MPGameMove(action: .match, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: matchMove)
                        
                    }
                    if matchResult == true && gameManager.multiplayerCards[authManager.username!]?.isEmpty == true {
                        gameManager.multiplayerPlayerFinishedCards(player: authManager.username!)
                        let playerFinish = MPGameMove(action: .playerFinish, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: playerFinish)
                        gameManager.multiplayerEndGame()
                    }
                    
                } label: {
                    let firstIconIndex = card.icons[0]
                    Text(gameManager.gameIcons[firstIconIndex] ?? "uhoh")
                        .rachaelsFontStyleMode(size: 50)
                    
                }
                .position(x: 175.0, y: 175.0)
                
                ForEach(1..<(card.icons.count), id: \.self) { index in
                    let iconIndex = card.icons[index]
                    let angle = startAngle + deltaAngle * Double(index)
                    let xPos = 175.0 + cos(angle.radians) * radius
                    let yPos = 175.0 + sin(angle.radians) * radius
                    
                    Button{
                        let matchResult = gameManager.multiplayerAttemptMatch(curr_user: authManager.username!, selectedIcon: iconIndex)
                        if matchResult == true {
                            let matchMove = MPGameMove(action: .match, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                            multiPeerManager.send(gameMove: matchMove)
                        }
                        if matchResult == true && gameManager.multiplayerCards[authManager.username!]?.isEmpty == true {
                            gameManager.multiplayerPlayerFinishedCards(player: authManager.username!)
                            let playerFinish = MPGameMove(action: .playerFinish, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                            multiPeerManager.send(gameMove: playerFinish)
                            gameManager.multiplayerEndGame()
                        }
                    } label:{
                        Text( gameManager.gameIcons[iconIndex] ?? "\(iconIndex)")
                            .rachaelsFontStyleMode(size: 50)
                            .rotationEffect(angle)
                    }
                    .position(x: xPos, y: yPos)
                }
                
            }
                .frame(width: 350, height: 350)
        )
    }
}

struct MultiMainCardView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(MultiPeerConnectionManager.self) var multiPeerManager
    
    var radius: CGFloat = 100 // control distance from center
    
    private var startAngle: Angle {
        .degrees(22)
    }
    
    private var endAngle: Angle {
        .degrees(startAngle.degrees + 360.0)
    }
    
    private var deltaAngle: Angle {
        .degrees((360.0) / Double(SpotItCard.numberOfIcons-1)) // number of icons will be 8 but in case we increase
    }
    
    var body: some View {
        let mainCard = gameManager.multiplayerCards["main"]!.last!
        ZStack {
            Circle()
                .fill(Color.rachaelsBlue)
                .frame(width: 350, height: 350)
                .shadow(radius: 20)
            
            Button {
                let matchResult = gameManager.multiplayerAttemptMatch(curr_user: authManager.username!, selectedIcon: mainCard.icons[0])
                if matchResult == true {
                    let matchMove = MPGameMove(action: .match, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                    multiPeerManager.send(gameMove: matchMove)
                }
                if matchResult == true && gameManager.multiplayerCards[authManager.username!]?.isEmpty == true {
                    gameManager.multiplayerPlayerFinishedCards(player: authManager.username!)
                    let playerFinish = MPGameMove(action: .playerFinish, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                    multiPeerManager.send(gameMove: playerFinish)
                    gameManager.multiplayerEndGame()
                }
            } label: {
                let firstIconIndex = mainCard.icons[0]
                Text(gameManager.gameIcons[firstIconIndex] ?? "uhoh")
                    .rachaelsFontStyleMode(size: 50)
                    
            }
            .position(x: 175.0, y: 175.0)
            
            ForEach(1..<(mainCard.icons.count), id: \.self) { index in
                let iconIndex = mainCard.icons[index]
                let angle = startAngle + deltaAngle * Double(index)
                let xPos = 175.0 + cos(angle.radians) * radius
                let yPos = 175.0 + sin(angle.radians) * radius
                
                Button{
                    let matchResult = gameManager.multiplayerAttemptMatch(curr_user: authManager.username!, selectedIcon: iconIndex)
                    if matchResult == true {
                        let matchMove = MPGameMove(action: .match, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: matchMove)
                    }
                    if matchResult == true && gameManager.multiplayerCards[authManager.username!]?.isEmpty == true {
                        gameManager.multiplayerPlayerFinishedCards(player: authManager.username!)
                        let playerFinish = MPGameMove(action: .playerFinish, hostPlayer: gameManager.multiplayerHost, multiplayerCards: gameManager.multiplayerCards, finishTimes: gameManager.multiplayerElapsedTimes, players: gameManager.multiplayerPlayers)
                        multiPeerManager.send(gameMove: playerFinish)
                        gameManager.multiplayerEndGame()
                    }
                } label:{
                    Text( gameManager.gameIcons[iconIndex] ?? "\(iconIndex)")
                        .rachaelsFontStyleMode(size: 50)
                        .rotationEffect(angle)
                }
                .position(x: xPos, y: yPos)
            }
            
        }
        .frame(width: 350, height: 350)
    }
    
}

#Preview {
    let gameManager = GameViewModel()
    ZStack{
        VStack {
            Spacer()
            //MARK: Card to Match
            MainCardView()
                .environment(NetworkManager())
                .environment(AuthManager())
                .environment(gameManager)
                .scaleEffect(0.5)
                .frame(width: 150, height: 150)
            Spacer()
            CardView()
                .environment(NetworkManager())
                .environment(AuthManager())
                .environment(gameManager)
            Spacer()
        }
    }
    .rachaelsBackgroundColor()
}

