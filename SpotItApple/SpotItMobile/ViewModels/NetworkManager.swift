//
//  NetworkManager.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/7/26.
//  Copied From:
//  NetworkManager.swift
//  Pokedex
//  Created by Nader Alfares on 3/6/26.
import Foundation
import SwiftUI


@Observable
class NetworkManager {
    static let ipAddress : String = "http://127.0.0.1:8000" // change to your specific ip address if you want to run on your phone
    private var authManager: AuthManager?
    
    func configure(with authManager: AuthManager) {
        //provide access to authManager singlton (single source of truth)
        self.authManager = authManager
    }
    
    //MARK: sign up
    func signup(username: String, password: String) async throws -> TokenResponse {
        guard let url = URL(string: "\(NetworkManager.ipAddress)/auth/signup") else {
            throw NetworkError.invalidURL
        }
        
        let payload = SignupRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 400 {
            let decoder = JSONDecoder()
            let fullResponse = try decoder.decode(HTTPURLResponseDetail.self, from: data)
            if fullResponse.detail == "Username already registered" {
                throw NetworkError.usernameAlreadyRegistered
            }
            if fullResponse.detail == "Username cannot contain spaces" {
                throw NetworkError.usernameContainsSpaces
            }
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(TokenResponse.self, from: data)
    }

    
    //MARK: - Log in
    func login(username: String, password: String) async throws -> TokenResponse {
        //TODO: Implement API request for user login
        guard let url = URL(string: "\(NetworkManager.ipAddress)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        let payload = LoginRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.invalidCredentials
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(TokenResponse.self, from: data)
    }
    
    func storeLeaderboardStat(time: Float) async throws -> StatEntry {
        //TODO: Implement API request for storing leaderboard score
        guard let url = URL(string: "\(NetworkManager.ipAddress)/leaderboard") else {
            throw NetworkError.invalidURL
        }
        
        let payload = StoreStatRequest(time: time)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authManager?.userAccessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.invalidCredentials
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(StatEntry.self, from: data)
    }
    
    func getLeaderboard() async throws -> [StatEntry] {
        guard let url = URL(string: "\(NetworkManager.ipAddress)/leaderboard") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = authManager?.userAccessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([StatEntry].self, from: data)
    }
    
    func storeUserIcons(token: String, icons: [Int: String]) async throws -> [Int: String] {
        guard let url = URL(string: "\(NetworkManager.ipAddress)/userIcons") else {
            throw NetworkError.invalidURL
        }
        let payload = icons.reduce(into:  [String : String]()) { $0[String($1.key)] = $1.value }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(["icons" : payload])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if httpResponse.statusCode == 401 {
            throw NetworkError.invalidCredentials
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let iconDict = try decoder.decode([String: String].self, from: data)
        
        let icons = iconDict.reduce(into: [Int:String]()) { result, element in
            let (key, value) = element
            if let intKey = Int(key) {
                result[intKey] = value
            }
        }
        
        return icons
    }
    
    func getUserIcons() async throws -> [Int: String] {
        guard let url = URL(string: "\(NetworkManager.ipAddress)/userIcons") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        if let token = authManager?.userAccessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let iconDict = try decoder.decode([String: String].self, from: data)
        
        let icons = iconDict.reduce(into: [Int:String]()) { result, element in
            let (key, value) = element
            if let intKey = Int(key) {
                result[intKey] = value
            }
        }
        
        return icons
    }
    
    // MARK: Network Errors
    enum NetworkError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
        case unauthorized
        case invalidCredentials
        case usernameAlreadyRegistered
        case couldNotDecodeIcons
        case usernameContainsSpaces
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The URL is invalid."
            case .invalidResponse:
                return "The server response was invalid."
            case .httpError(let statusCode):
                return "Request failed with status code: \(statusCode)"
            case .unauthorized:
                return "You need to log in to access this resource."
            case .invalidCredentials:
                return "Invalid username or password."
            case .usernameAlreadyRegistered:
                return "This Username is already registered."
            case .couldNotDecodeIcons:
                return "Could not get Icons from server."
            case .usernameContainsSpaces:
                return "Username cannot contain spaces."
            }
        }
    }
}





