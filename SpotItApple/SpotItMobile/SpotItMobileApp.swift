//
//  SpotItMobileApp.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

import SwiftUI

@main
struct SpotItMobileApp: App {
    @State var authManager = AuthManager()
    @State var networkManager = NetworkManager()
    @State var gameManager = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(authManager)
                .environment(networkManager)
                .environment(gameManager)
                .onAppear {
                    networkManager.configure(with: authManager)
                }
        }
    }
}
