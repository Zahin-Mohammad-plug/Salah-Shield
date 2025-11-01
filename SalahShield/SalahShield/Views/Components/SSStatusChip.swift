//
//  SSStatusChip.swift
//  SalahShield
//
//  Created by Zahin M on 2025-11-01.
//

import SwiftUI

/// Status chip component for displaying app state
struct SSStatusChip: View {
    let status: AppStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            
            Text(status.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.15))
        .cornerRadius(20)
        .accessibilityLabel("Status: \(status.title)")
    }
}
