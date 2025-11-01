//
//  DesignSystem.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Design system constants and tokens
enum DesignSystem {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Font Sizes
    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title3: CGFloat = 20
        static let title2: CGFloat = 24
        static let title1: CGFloat = 32
        static let large: CGFloat = 40
    }
    
    // MARK: - Colors
    enum Colors {
        static let primary = Color("PrimaryColor", bundle: nil)
        static let secondary = Color("SecondaryColor", bundle: nil)
        static let accent = Color.accentColor
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    }
    
    // MARK: - Shadows
    enum Shadow {
        static let light = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let heavy = Color.black.opacity(0.2)
    }
}
