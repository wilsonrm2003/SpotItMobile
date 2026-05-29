//
//  SpotItCard.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/7/26.
//
import Foundation

struct SpotItCard: Codable, Identifiable, Hashable {
    var id = UUID()
    var isMatched : Bool = false
    static let numberOfIcons: Int = 8
    
    let icons : [Int]
    // each card has 8 icons listed by their index number
}

//default main card for testing
let default_main_card: SpotItCard = SpotItCard(icons: [0, 1, 2, 3, 4, 5, 6, 7])
let default_card: SpotItCard = SpotItCard(icons: [0, 8, 9, 10, 11, 12, 13, 15])

enum SpotItIcon: String, CaseIterable {
    case dog = "🐕"
    case cat = "🐈"
    case lock = "🔒"
    case key = "🔑"
    case turtle = "🐢"
    case plane = "✈️"
    case train = "🚂"
    case cookie = "🍪"
    case apple = "🍏"
    case target = "🎯"
    case clown = "🤡"
    case peace = "✌️"
    case heart = "❤️"
    case lips = "👄"
    case crown = "👑"
    case sun = "☀️"
    case moon = "🌖"
    case clock = "🕰️"
    case babyBottle = "🍼"
    case microphone = "🎤"
    case coffee = "☕️"
    case strawberry = "🍓"
    case ghost = "👻"
    case trophy = "🏆"
    case hockeyStick = "🏒"
    case taxi = "🚕"
    case anchor = "⚓️"
    case phone = "📞"
    case camera = "📸"
    case clover = "🍀"
    case pawPrints = "🐾"
    case books = "📚"
    case money = "💸"
    case pencil = "✏️"
    case scissors = "✂️"
    case eightBall =  "🎱" 
    case watermelon =  "🍉" 
    case rainbow = "🌈"
    case toilet = "🚽"
    case lightning = "⚡️"
    case umbrella = "☂️"
    case snowman = "☃️"
    case present = "🎁"
    case mapleLeaf = "🍁"
    case popcorn = "🍿"
    case horse = "🐎"
    case dolphin = "🐬"
    case chicken = "🐓"
    case hamburger = "🍔"
    case frenchFries = "🍟"
    case star = "⭐️"
    case fingersCrossed = "🤞"
    case beggingFace = "🥺"
    case lotusFlower = "🪷"
    case smilingHearts = "🥰"
    case peekingFace = "🫣"
    case salute = "🫡"
}
