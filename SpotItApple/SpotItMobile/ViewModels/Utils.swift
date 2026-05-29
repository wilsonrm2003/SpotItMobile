//
//  Utils.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

import Foundation
import SwiftUI

// rachael's background color (its like red to red for dark mode, blue to lavednar for light)
struct RachaelsBackgroundColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isLight: Bool
    
    func body(content: Content) -> some View {
        ZStack{
            colorScheme == .light ? Color.rachaelsGradientBluetoLav.ignoresSafeArea() : Color.rachaelsGradientRed.ignoresSafeArea()
            content
        }
    }
}

// custom font / colors
struct RachaelsFontStyle : ViewModifier {
    // can change size,weight,and color but only have to do it in one line and keeps the serif
    let size : CGFloat
    let color : Color
    let weight : Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: .serif))
            .foregroundStyle(color)
    }
}

struct RachaelsFontStyleMode: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let size : CGFloat
    let weight : Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: .serif))
            .foregroundStyle(colorScheme == .light ? Color.rachaelsRed : Color.rachaelsPink)
    }
}

extension View {
    func rachaelsBackgroundColor(isLight: Bool = true) -> some View {
        modifier(RachaelsBackgroundColor(isLight: isLight))
    }
    
    func rachaelsFontStyleMode(size: CGFloat = 16, weight: Font.Weight = .black) -> some View {
        modifier(RachaelsFontStyleMode(size: size, weight: weight))
    }
    
    func rachaelsFontStyle(size: CGFloat = 16, color: Color = .rachaelsPink, weight: Font.Weight = .black) -> some View {
        modifier(RachaelsFontStyle(size: size, color: color, weight: weight))
    }
}

extension Color {
    static let rachaelsPink = Color(red: 1, green: 0.7176, blue: 0.8745) // baby pink
    static let pennStatePink = Color(red: 0.737, green: 0.125, blue: 0.294) // penn states og color
    static let rachaelsRed = Color(red: 0.3765, green: 0, blue: 0.0431) // dark red
    static let rachaelsLavender = Color(red: 0.6745, green: 0.5529, blue: 0.8078) // lavendar
    static let rachaelsBlue = Color(red: 0.588, green: 0.745, blue: 0.902) // baby blue
    static let rachaelsNavy = Color(red: 0, green: 0.118, blue: 0.267) // navy blue current color
    static let rachaelPurple = Color(red: 0.286, green: 0.114, blue: 0.439) // dark purple
    
    static let rachaelsGradientRed = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.3765, green: 0, blue: 0.0431),
            Color(red: 0.4667, green: 0, blue: 0.0745),
            Color(red: 0.7176, green: 0, blue: 0.1294)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let rachaelsGradientBluetoLav = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.588, green: 0.745, blue: 0.902),
            Color(red: 0.6745, green: 0.5529, blue: 0.8078)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
