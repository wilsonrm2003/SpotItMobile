//
//  LoginView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(NetworkManager.self) private var networkManager
    @Environment(AuthManager.self) private var authManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showSignIn: Bool
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSignup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    HStack {
                        Button {
                            showSignIn = false
                            
                        } label: {
                            Image(systemName: "house")
                                .rachaelsFontStyleMode(size: 25)
                                .padding(7)
                                .background(Circle().fill(.ultraThinMaterial))
                                .shadow(radius: 5)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Spacer()
                    
                    Text("Sign In")
                        .rachaelsFontStyleMode(size: 30)
                    
                    Text("To access Multiplayer and the Leaderboard")
                        .rachaelsFontStyleMode(size: 14, weight: .regular)
                        .padding([.bottom])
                    
                    //MARK: Login Form
                    VStack (spacing: 10) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .rachaelsFontStyleMode()
                            
                            TextField("", text: $username)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.alphabet)
                                .autocorrectionDisabled()
                                
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .rachaelsFontStyleMode()
                            
                            SecureField("", text: $password)
                            
                                .textFieldStyle(AuthTextFieldStyle())
                                
                        }
                        .padding(.bottom)
                        
                        // Login Button
                        Button(action: login) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.rachaelsBlue)
                                } else {
                                    Text("Log In")
                                        .rachaelsFontStyleMode(size: 16)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(colorScheme == .light ? Color.rachaelsBlue : Color.rachaelsNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        }
                        .disabled(isLoading || username.isEmpty || password.isEmpty)
                        
                        // Sign Up Link
                        Button {
                            showSignup = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .rachaelsFontStyleMode()
                                    
                                Text("Sign Up")
                                    .rachaelsFontStyleMode(weight: .bold)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showSignup) {
                SignupView()
            }
            .rachaelsBackgroundColor()
        }
    }
    
    // MARK: - Actions
    private func login() {
        Task {
            do {
                let response = try await networkManager.login(username: username, password: password)
                authManager.setUser(username: username, response.userAccessToken)
            } catch {
                handleError("Login Error", error: error)
            }
        }
    }
    
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
    
}
// MARK: - Custom Text Field Style

struct AuthTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .rachaelsFontStyleMode(size: 14)
            .padding()
            .background(colorScheme == .light ? Color.rachaelsBlue : Color.rachaelsNavy)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

//#Preview {
//    LoginView()
//        .environment(NetworkManager())
//        .environment(AuthManager())
//}

