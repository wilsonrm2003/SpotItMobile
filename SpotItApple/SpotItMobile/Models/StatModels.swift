//
//  StatModels.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 4/8/26.
//
import Foundation

struct StatEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    let username: String
    let time: Float
    
    enum CodingKeys: String, CodingKey {
        case username, time
    }
    
    init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        self.username = try! container.decode(String.self, forKey: .username)
        self.time = try! container.decode(Float.self, forKey: .time)
    }
    
    init(username: String, time: Float) {
        self.username = username
        self.time = time
    }
}

struct GameStats {
    var localStats: [StatEntry] = []
    var networkStats: [StatEntry] = []
    var unsavedStats: [StatEntry] = []
    var gameStats : Set<StatEntry> {
        let filtered_local = localStats.filter{ localStat in
            networkStats.contains(where: {$0.username == localStat.username}) == false
        }
        return Set(filtered_local).union(Set(networkStats))
    }
    
    private let networkFilename = "networkSpotItStats"
    private let unsavedStatsFilename = "unsavedSpotItStats"
    
    init() {
        loadStoredNetwork(filename: networkFilename)
        loadUnsavedStats(filename: unsavedStatsFilename)
    }
    
    var bestTime: Float? {
        gameStats.min(by: { $0.time < $1.time })?.time
    }
    
    mutating func addStat(username: String, time: Float) {
        localStats.append(
            StatEntry(username: username, time: time)
        )
    }
    
    mutating func loadStoredNetwork(filename: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(filename).json")
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    networkStats = try decoder.decode([StatEntry].self, from: data)
                    print("Successfully loaded stats from: \(fileURL.path)")
                    return
                } catch {
                    print("Failed to load network stats from documents: \(error)")
                }
            }
        }
        
        // Fallback: Try to load from bundle (initial data)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found in bundle, starting with empty stats")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            networkStats = try decoder.decode([StatEntry].self, from: data)
            print("Successfully loaded stats from bundle")
        } catch {
            print("Failed to load network stats JSON: \(error)")
        }
        
    }
    
    func save() {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(networkStats)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("\(networkFilename).json")
                try data.write(to: fileURL)
                
                print("Successfully saved stats to: \(fileURL.path)")
            }
        } catch {
            print("Failed to save json", error)
        }
    }
    
    mutating func addUnsavedStat(username: String, time: Float) {
        unsavedStats.append(
            StatEntry(username: username, time: time)
        )
    }
    
    mutating func loadUnsavedStats(filename: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent("\(filename).json")
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    unsavedStats = try decoder.decode([StatEntry].self, from: data)
                    print("Successfully loaded stats from: \(fileURL.path)")
                    return
                } catch {
                    print("Failed to load network stats from documents: \(error)")
                }
            }
        }
        
        // Fallback: Try to load from bundle (initial data)
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found in bundle, starting with empty stats")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            unsavedStats = try decoder.decode([StatEntry].self, from: data)
            print("Successfully loaded stats from bundle")
        } catch {
            print("Failed to load network stats JSON: \(error)")
        }
        
    }
    
    func saveNotConnected() {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(unsavedStats)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("\(unsavedStatsFilename).json")
                try data.write(to: fileURL)
                
                print("Successfully saved stats to: \(fileURL.path)")
            }
        } catch {
            print("Failed to save json", error)
        }
    }
    
}


struct StoreStatRequest: Codable {
    let time: Float
}
