//
//  SignupView.swift
//  Pokedex
//
//  Created by Rachael Wilson on 4/2/26.
//
import SwiftUI

struct SignupView: View {
    @Environment(NetworkManager.self) private var networkManager
    @Environment(AuthManager.self) private var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo/Title
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .rachaelsFontStyleMode(size: 80)
                            .foregroundStyle(.white)
                        
                        Text("Create Account")
                            .rachaelsFontStyleMode(size: 36)
                    }
                    
                    
                    //MARK: Signup Form
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .rachaelsFontStyleMode(size: 15, weight: .bold)
                            
                            TextField("", text: $username)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.alphabet)
                                .autocorrectionDisabled()
                            
                            if (username.contains(" ")) {
                                Text("Username cannot contain Spaces")
                                    .rachaelsFontStyleMode(size: 12, weight: .regular)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .rachaelsFontStyleMode(size: 15, weight: .bold)
                            
                            SecureField("", text: $password)
                                .textFieldStyle(AuthTextFieldStyle())
                            
                            if (password.count < 6) {
                                Text("Password must be at least 6 characters.")
                                    .rachaelsFontStyleMode(size: 12, weight: .regular)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .rachaelsFontStyleMode(size: 15, weight: .bold)
                            
                            SecureField("", text: $confirmPassword)
                                .textFieldStyle(AuthTextFieldStyle())
                        }
                        
                        // Error message for password mismatch
                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords don't match")
                                .rachaelsFontStyle(color:.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        //MARK: Sign Up Button
                        Button{
                            signup()
                        }label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.rachaelsBlue)
                                } else {
                                    Text("Sign Up")
                                        .rachaelsFontStyleMode(size: 24)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(colorScheme == .light ? Color.rachaelsBlue : Color.rachaelsNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isLoading || !isValidForm)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }.rachaelsBackgroundColor()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle( colorScheme == .light ? .black : .white)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValidForm: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    // MARK: - Actions
    
    private func signup() {
        //TODO: signup action
        Task {
            do {
                let response = try await networkManager.signup(username: username, password: password)
                let _ = try await networkManager.storeUserIcons(token: response.userAccessToken, icons: gameManager.gameIcons)
                authManager.setUser(username: username, response.userAccessToken)
                dismiss()
            } catch {
                //print("sign up error: \(error)")
                handleError("Sign Up Error", error: error)
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

#Preview {
    SignupView()
        .environment(NetworkManager())
        .environment(AuthManager())
        .environment(GameViewModel())
}
