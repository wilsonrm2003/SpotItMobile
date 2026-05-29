//
//  ChangeIconView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/9/26.
//
import SwiftUI

struct ChangeIconView: View {
    @Environment(GameViewModel.self) var gameManager
    
    let cols =  [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @Binding var showChangeIcons: Bool
    @State var showEmojiChanger: Bool = false
    @State var oldIndex: Int = 0
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    Button {
                        showChangeIcons = false
                    } label: {
                        Text("Close")
                            .rachaelsFontStyleMode(size: 20)
                    }
                    
                    Spacer()
                    
                    Text("Change Icons")
                        .rachaelsFontStyleMode(size: 30)
                    
                    Spacer()
                    
                }
                .padding()
                
                ScrollView(.vertical) {
                    LazyVGrid(columns: cols, spacing: 20) {
                        ForEach(Array(gameManager.gameIcons.keys).sorted {$0 < $1}, id: \.self) { iconIndex in
                            Button {
                                showEmojiChanger = true
                                oldIndex = iconIndex
                            } label: {
                                VStack{
                                    Text( gameManager.gameIcons[iconIndex] ?? String(iconIndex))
                                        .rachaelsFontStyleMode(size: 80)
                                }
                                .padding(9)
                                .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                            }
                            .disabled(showEmojiChanger) // disable the buttons when one of the changers is active
                        }
                    }
                }
            }
            .rachaelsBackgroundColor()
            
            if (showEmojiChanger) {
                EmojiChangerView(showEmojiChanger: $showEmojiChanger, oldIndex: oldIndex)
            }
        }
    }
}

//MARK: emoji changer popup
struct EmojiChangerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(GameViewModel.self) var gameManager
    @Environment(AuthManager.self) var authManager
    @Environment(NetworkManager.self) var networkManager
    
    @Binding var showEmojiChanger: Bool
    
    let oldIndex : Int
    @State var newEmoji : String = ""
    @State var showError : Bool = false
    @State var errorMessage : String = ""
    
    private func handleError(_ message: String, error: Error) {
        // Check if error is unauthorized
        if case NetworkManager.NetworkError.unauthorized = error {
            //TODO: uncomment for logout
            authManager.resetAuthState()
            return
        }
        
        errorMessage = "\(message): \(error.localizedDescription)"
        showError = true
    }
    
    private func isBadIcon() -> Bool {
        if (newEmoji == "" || newEmoji.count > 1) {
            return true
        } else {
            return false
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    showEmojiChanger = false
                } label: {
                    HStack {
                        Text("Cancel")
                            .rachaelsFontStyleMode(size: 20)
                    }
                    .padding(6)
                    .background(Capsule().fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
                }
                Spacer()
                Text("Select a New Emoji to Change")
                    .rachaelsFontStyleMode(size: 20)
                Spacer()
            }
            
            HStack {
                Spacer()
                VStack{
                    Text("Old Emoji")
                        .rachaelsFontStyleMode()
                    Text( gameManager.gameIcons[oldIndex] ?? String(oldIndex))
                        .rachaelsFontStyleMode(size: 80)
                }.padding(9)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                
                Spacer()
                Spacer()
                
                VStack{
                    Text("New Emoji")
                        .rachaelsFontStyleMode()
                    
                    TextField("", text: $newEmoji)
                        .rachaelsFontStyleMode(size: 80)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(9)
                .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
                Spacer()
            }
            
            if (isBadIcon() == true) {
                Text("Emoji must be exactly one character")
                    .rachaelsFontStyleMode(size: 12)
            }
            
            
            Button {
                Task {
                    do {
                        try gameManager.changeIcon(iconIndex: oldIndex, newIcon: newEmoji)
                        let _ = try await networkManager.storeUserIcons(token: authManager.userAccessToken ?? "", icons: gameManager.gameIcons)
                        showEmojiChanger = false
                    } catch {
                        handleError("Change Error", error: error)
                    }
                }
                
            } label: {
                Text("Change It!")
                    .rachaelsFontStyleMode()
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(colorScheme == .light ? Color.rachaelsPink : Color.rachaelsNavy))
            }.disabled(isBadIcon() == true)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(.ultraThinMaterial))
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    VStack{
        Text("testing ;)")
    }
    .rachaelsBackgroundColor()
    .sheet(isPresented: .constant(true)){ ChangeIconView(showChangeIcons: .constant(true))
    }
    .environment(GameViewModel())
}
