//
//  SSCard.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Reusable card component
struct SSCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    
    init(padding: CGFloat = DesignSystem.Spacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: DesignSystem.Shadow.light, radius: 8, y: 4)
    }
}
