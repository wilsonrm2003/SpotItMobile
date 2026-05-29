//
//  AccountView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/10/26.
//
import SwiftUI

struct UserLoggedCheckView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showAccount: Bool
    
    var body: some View {
        if authManager.userIsLoaded {
            AccountView(showAccount: $showAccount)
        } else {
            LoginView(showSignIn: $showAccount)
        }
    }
}

struct AccountView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showAccount: Bool
    @State var showChangeIcons: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        showAccount = false
                    } label: {
                        Image(systemName: "house")
                            .rachaelsFontStyleMode(size: 25)
                            .padding(7)
                            .background(Circle().fill(.ultraThinMaterial))
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    Text("Account")
                        .rachaelsFontStyleMode(size: 30)
                    
                    Spacer()
                }.padding(.horizontal)
                Spacer()
                
                HStack {
                    Text("Username")
                        .rachaelsFontStyleMode()
                        .underline()
                    
                    Spacer()
                    
                    Text("\(authManager.username ?? "No username")")
                        .rachaelsFontStyleMode()
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                .shadow(radius: 10)
                .padding()
                
                Spacer()
                
                //MARK: Icon buttons
                HStack {
                    
                    Button{
                        showChangeIcons = true
                    } label: {
                        Text("Change Icons")
                            .rachaelsFontStyleMode(size: 20)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                    }
                    
                    Spacer()
                    
                    Button{
                        gameManager.resetDefaultIcons()
                    } label: {
                        Text("Reset Icons")
                            .rachaelsFontStyleMode(size: 20)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                    }
                    
                }.padding()
                
                Spacer()
                
                Button {
                    authManager.resetAuthState()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .rachaelsFontStyle(size: 20, color: .red)
                        Text("Log Out")
                            .rachaelsFontStyle(color: .red)
                    }
                }
                .padding()
            }

            .rachaelsBackgroundColor()
            .sheet(isPresented: $showChangeIcons) {
                ChangeIconView(showChangeIcons: $showChangeIcons)
            }
        }
    }
}

#Preview {
    AccountView(showAccount: .constant(true))
        .environment(AuthManager())
        .environment(NetworkManager())
        .environment(GameViewModel())
}
