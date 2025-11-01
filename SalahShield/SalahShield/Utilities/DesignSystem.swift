//
//  DesignSystem.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Primary
        static let primary = Color("Primary", bundle: nil)
        static let primaryLight = Color("PrimaryLight", bundle: nil)
        static let primaryDark = Color("PrimaryDark", bundle: nil)
        
        // Background
        static let background = Color("Background", bundle: nil)
        static let secondaryBackground = Color("SecondaryBackground", bundle: nil)
        static let cardBackground = Color("CardBackground", bundle: nil)
        
        // Text
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let tertiaryText = Color.gray
        
        // Status
        static let active = Color.green
        static let inactive = Color.gray
        static let warning = Color.orange
        static let error = Color.red
        
        // Fallback colors for when custom colors aren't defined
        static let accentColor = Color.accentColor
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let bodyBold = Font.body.weight(.semibold)
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let card = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        static let button = Shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}
