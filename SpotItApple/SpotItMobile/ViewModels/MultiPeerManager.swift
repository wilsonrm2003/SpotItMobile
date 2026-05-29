//
//  MultiPeerManager.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/28/26.
//

import MultipeerConnectivity

extension String {
    static var serviceName = "SpotIt"
}

@Observable
class MultiPeerConnectionManager: NSObject {
    let serviceType = String.serviceName
    let session: MCSession
    let peerId: MCPeerID
    let browserService: MCNearbyServiceBrowser
    let advertiserService: MCNearbyServiceAdvertiser
    var gameManager: GameViewModel? // use the other environment as a variable to access it's infornmation within this environment
    
    func setup(game: GameViewModel) {
        self.gameManager = game // activate the game manager ;)
    }
    
    var availablePeers = [MCPeerID]()
    var recievedInvite: Bool = false
    var recievedInviteFrom: MCPeerID?
    var invitationHandler: ((Bool, MCSession?) -> Void)?
    var paired: Bool = false
    
    var isMultiReady: Bool = false {
        didSet {
            if isMultiReady {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    } // when we are ready to look for multiplayer, begin advertising , if not stop
    
    init(username: String) {
        peerId = MCPeerID(displayName: username)
        session = MCSession(peer: peerId)
        browserService = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        advertiserService = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        super.init()
        session.delegate = self
        browserService.delegate = self
        advertiserService.delegate = self
    }
    
    deinit { // when class is not initialized stop the multipeer activities
        stopBrowsing()
        stopAdvertising()
    }
    
    func startBrowsing() {
        browserService.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browserService.stopBrowsingForPeers()
        availablePeers.removeAll() // clear available peers when stoping
    }
    
    func startAdvertising() {
        advertiserService.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiserService.stopAdvertisingPeer()
    }
    
    func send(gameMove: MPGameMove) {
        if !(session.connectedPeers.isEmpty) {
            do {
                if let data = gameMove.data() {
                    try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                }
            } catch {
                print("error sending data: \(error.localizedDescription)")
            }
        }
    }
}

extension MultiPeerConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let index = availablePeers.firstIndex(of: peerID) else { return }
        DispatchQueue.main.async {
            self.availablePeers.remove(at: index)
        }
    }
}

extension MultiPeerConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.recievedInvite = true
            self.recievedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MultiPeerConnectionManager: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async {
                self.paired = false
                self.isMultiReady = true
            }
        case .connected:
            DispatchQueue.main.async {
                self.paired = true
                if self.gameManager?.multiplayerHost == self.peerId.displayName {
                    self.gameManager?.enterLobbyMulti(curr_user: peerID.displayName)
                    let lobbyMsg = MPGameMove(action: .lobbyEnter, hostPlayer: self.gameManager?.multiplayerHost, multiplayerCards: nil, finishTimes: nil, players: self.gameManager?.multiplayerPlayers ?? [])
                    self.send(gameMove: lobbyMsg)
                }
                self.isMultiReady = false
            }
        default:
            DispatchQueue.main.async {
                self.paired = false
                self.isMultiReady = true
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let gameMove = try? JSONDecoder().decode(MPGameMove.self, from: data) {
            DispatchQueue.main.async {
                switch gameMove.action {
                case .lobbyEnter: // entering lobby not host
                    self.gameManager!.recieveLobbyInfo(host: gameMove.hostPlayer!, players: gameMove.players!)
                case .playerLeaving: // host has kicked someone from game must update player lists or someone leaves
                    self.gameManager!.recievePlayerLeaving(players: gameMove.players!)
                case .start: // host sending deck order and player list
                    self.gameManager!.recieveStartGame(recievedMultiCards: gameMove.multiplayerCards!, players: gameMove.players!)
                case .match: // player matched a card, update decks
                    self.gameManager!.recieveMatch(recievedMultiCards: gameMove.multiplayerCards!)
                case .playerFinish: // a player has finished their deck
                    self.gameManager!.recievePlayerFinish(recievedMultiCards: gameMove.multiplayerCards!, recievedMultiFinishTimes: gameMove.finishTimes!)
                    self.gameManager!.multiplayerEndGame()
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}
