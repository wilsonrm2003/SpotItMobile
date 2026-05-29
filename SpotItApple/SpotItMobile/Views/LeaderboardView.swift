//
//  LeaderboardView.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//
import SwiftUI

struct LeaderboardView: View {
    @Environment(NetworkManager.self) var networkManager
    @Environment(AuthManager.self) var authManager
    @Environment(GameViewModel.self) var gameManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showLeaderboard: Bool
    
    private var sortedStats: [StatEntry] {
        Array(gameManager.gameStats.gameStats).sorted { $0.time < $1.time }
    }
    
    private func formatTime(_ seconds: Float) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let miliseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, secs, miliseconds)
    }
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    showLeaderboard = false
                } label: {
                    Image(systemName: "house")
                        .rachaelsFontStyleMode(size: 25)
                        .padding(7)
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                Text("Leaderboard")
                    .rachaelsFontStyleMode(size: 30)
                
                Spacer()
            }
            ScrollView{
                if (sortedStats == []) {
                    Text("No Scores Recorded Yet!")
                        .rachaelsFontStyleMode(size: 20)
                }
                ForEach(Array(sortedStats.enumerated()), id: \.element.id) { index, stat in
                    LeaderboardRow(
                        rank: index + 1,
                        stat: stat,
                        formatTime: formatTime
                    )
                }.padding(3)
            }
            Text(authManager.userIsLoaded ? "Your Scores are Highlighed!" : "Log in to see Yourself on the Leaderboard!")
                .rachaelsFontStyleMode()
        }
        .padding()
        .rachaelsBackgroundColor()
    }
}

struct LeaderboardRow: View {
    @Environment(AuthManager.self) var authManager
    @Environment(\.colorScheme) var colorScheme
    
    let rank: Int
    let stat: StatEntry
    let formatTime: (Float) -> String
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)."
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rankEmoji)
                .rachaelsFontStyleMode()
                .frame(width: 40)
            
            // Player Name and Difficulty
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.username)
                    .rachaelsFontStyleMode(weight: .bold)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .rachaelsFontStyleMode(size: 15, weight: .regular)
                    
                    Text(formatTime(stat.time))
                        .rachaelsFontStyleMode(weight: .bold)
                }
                .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((authManager.userIsLoaded && authManager.username == stat.username) ? (colorScheme == .light ? Color.rachaelsPink : Color.rachaelsBlue) : Color.clear, lineWidth: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rank <= 3 ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 4)
                )
                
        )
        .padding(.horizontal)
    }
}

#Preview {
    LeaderboardView(showLeaderboard: .constant(true))
        .environment(GameViewModel())
        .environment(NetworkManager())
        .environment(AuthManager())
}
