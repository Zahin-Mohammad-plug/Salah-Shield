//
//  SSButton.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Salah Shield custom button component
struct SSButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .semibold))
            }
            .frame(maxWidth: size == .large ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: style.shadowColor, radius: 4, y: 2)
        }
        .accessibilityLabel(title)
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case destructive
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return DesignSystem.Colors.secondaryBackground
            case .outline: return .clear
            case .destructive: return .red
            case .ghost: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .primary
            case .outline: return .accentColor
            case .destructive: return .white
            case .ghost: return .accentColor
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .primary, .destructive: return DesignSystem.Shadow.medium
            default: return .clear
            }
        }
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 17
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }
    }
}
