//
//  AuthManager.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/7/26.
//
//  Copied From:
//  AuthManager.swift
//  Pokedex
//  Created by Nader Alfares on 3/6/26.

import Foundation
import SwiftUI


@Observable
class AuthManager {
    //TODO: published properties for authenticated user
    private(set) var username: String?
    private(set) var userAccessToken: String?
    private(set) var userIsLoaded: Bool = false
    
    //(recommended) use in your views to show an alert for errors
    var errorMessage: String?
    
    //UserDefaults keys
    private let tokenKey = "spot_it_access_token"
    private let usernameKey = "spot_it_user_name"
    
    init() {
        // immediate login for persisted user credentials
        loadAuthUser()
    }
    
    func setUser(username: String, _ token: String) {
        //TODO: set authenticated user's credentials (login)
        saveToken(token)
        saveUsername(username)
        //self.userEmail = email
        //self.userAccessToken = token
        loadAuthUser()
    }
    
    func resetAuthState() {
        //TODO: reset propeties of AuthManager (logout)
        deleteToken()
        deleteUsername()
        self.username = nil
        self.userAccessToken = nil
        self.userIsLoaded = false
    }
    
    // MARK: - Private Methods
    // Helper functions for UserDefualts
    private func loadAuthUser() {
        var isLoadedUsername: Bool = false
        var isLoadedToken: Bool = false
        
        //TODO: load user credentials from UserDefaults
        if let username = UserDefaults.standard.string(forKey: usernameKey) {
            self.username = username
            isLoadedUsername = true
        }
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            self.userAccessToken = token
            isLoadedToken = true
        }
        
        if (isLoadedUsername && isLoadedToken) {
            self.userIsLoaded = true
        }
        
    }
    
    private func saveToken(_ token: String) {
        //TODO: save token in UserDefualts
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    private func deleteToken() {
        //TODO: save token in UserDefualts
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    private func saveUsername(_ username: String) {
        //TODO: save user email in UserDefualts
        UserDefaults.standard.set(username, forKey: usernameKey)
    }
    
    private func deleteUsername() {
        //TODO: delete user email in UserDefualts
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }
}

