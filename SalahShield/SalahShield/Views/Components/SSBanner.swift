//
//  SSBanner.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Information banner component for alerts and notifications
struct SSBanner: View {
    let message: String
    let type: BannerType
    let icon: String?
    let action: (() -> Void)?
    let dismissAction: (() -> Void)?
    
    init(
        message: String,
        type: BannerType = .info,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.type = type
        self.icon = icon
        self.action = action
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            let displayIcon = icon ?? type.defaultIcon
            Image(systemName: displayIcon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(type.color)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Text("Fix")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(type.color)
                }
            }
            
            if let dismissAction = dismissAction {
                Button(action: dismissAction) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(type.backgroundColor)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
    
    enum BannerType {
        case info
        case warning
        case error
        case success
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .error: return .red
            case .success: return .green
            }
        }
        
        var backgroundColor: Color {
            color.opacity(0.1)
        }
        
        var defaultIcon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .success: return "checkmark.circle.fill"
            }
        }
    }
}
