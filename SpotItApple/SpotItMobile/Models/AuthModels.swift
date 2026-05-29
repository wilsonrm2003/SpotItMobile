//
//  AuthModels.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/7/26.
//  Copied From:
//  AuthModels.swift
//  Taskly
//
//  Created by Nader Alfares on 3/16/26.
//
import Foundation

// MARK: - Request Models
struct SignupRequest: Codable {
    let username: String
    let password: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

// MARK: - Response Models

struct TokenResponse: Codable {
    let userAccessToken: String
    let tokenType: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case userAccessToken = "access_token"
        case tokenType = "token_type"
        case user = "user"
    }
}

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    
    static let standard = User(id: 1, username: "user")
}

struct HTTPURLResponseDetail: Codable {
    let detail: String
}
