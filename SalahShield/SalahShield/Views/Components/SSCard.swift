//
//  SSCard.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
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
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
}
