//
//  SSListRow.swift
//  SalahShield
//
//  Created on November 1, 2025.
//

import SwiftUI

/// Reusable list row component
struct SSListRow: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color?
    let accessory: Accessory
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        accessory: Accessory = .none,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: DesignSystem.Spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor ?? .accentColor)
                        .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                accessoryView
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
        case .text(let text):
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        case .badge(let count):
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor)
                .cornerRadius(12)
        }
    }
    
    enum Accessory {
        case none
        case chevron
        case toggle(Binding<Bool>)
        case text(String)
        case badge(Int)
    }
}
