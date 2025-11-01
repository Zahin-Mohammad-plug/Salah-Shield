# Component Library Documentation

## Overview
Salah Shield uses a comprehensive component library built with SwiftUI that ensures consistency, accessibility, and maintainability across the entire app.

## Design Principles

1. **Consistency**: All components follow the same design language
2. **Accessibility**: Built-in VoiceOver support and large tap targets
3. **Flexibility**: Configurable through parameters
4. **Reusability**: Single implementation, used everywhere
5. **Type Safety**: Leverages Swift's type system

## Components

### SSButton

A versatile button component with multiple styles and sizes.

**Styles:**
- `primary`: Accent color background, white text
- `secondary`: Secondary background, primary text
- `outline`: Clear background, accent border
- `destructive`: Red background, white text
- `ghost`: Clear background, accent text

**Sizes:**
- `small`: 36pt height
- `medium`: 44pt height (Apple recommended)
- `large`: 52pt height

**Example:**
```swift
SSButton("Get Started", icon: "arrow.right", style: .primary, size: .large) {
    performAction()
}
```

---

### SSCard

Container component with consistent padding and shadow.

**Example:**
```swift
SSCard {
    VStack {
        Text("Title")
        Text("Content")
    }
}

// Custom padding
SSCard(padding: 24) {
    // Content
}
```

---

### SSStatusChip

Status indicator with color-coded states.

**States:**
- Active (Green)
- Idle (Gray)
- Paused (Orange)
- Needs Setup (Red)

**Example:**
```swift
SSStatusChip(status: appState.currentStatus)
```

---

### SSBanner

Information/warning/error banner with optional actions.

**Types:**
- `info`: Blue
- `warning`: Orange
- `error`: Red
- `success`: Green

**Example:**
```swift
SSBanner(
    message: "Location access required",
    type: .warning,
    action: { openSettings() },
    dismissAction: { dismiss() }
)
```

---

### SSListRow

Flexible list row with multiple accessory types.

**Accessories:**
- `none`: No accessory
- `chevron`: Navigation arrow
- `toggle`: Switch control
- `text`: Text label
- `badge`: Count indicator

**Example:**
```swift
SSListRow(
    title: "Notifications",
    subtitle: "Get prayer reminders",
    icon: "bell.fill",
    iconColor: .blue,
    accessory: .toggle($enabled),
    action: { /* tap action */ }
)
```

---

### SSEmptyState

Placeholder for empty screens with optional action.

**Example:**
```swift
SSEmptyState(
    icon: "shield.slash",
    title: "No Blocklists",
    message: "Create your first blocklist to start",
    actionTitle: "Create Blocklist",
    action: { showCreate() }
)
```

---

## Custom Views

### NextPrayerCard
Large card showing the upcoming prayer with countdown.

### PrayerRowCard
Compact prayer time row for list views.

### PrayerScheduleCard
Detailed prayer card with visual timeline.

### TimelineView
Visual representation of prayer window with buffers.

### ProFeatureRow
Feature highlight for paywall screen.

### ModeCard
Special mode card with toggle and details.

---

## Design System Tokens

Access via `DesignSystem` enum:

### Spacing
```swift
DesignSystem.Spacing.xs   // 4pt
DesignSystem.Spacing.sm   // 8pt
DesignSystem.Spacing.md   // 16pt
DesignSystem.Spacing.lg   // 24pt
DesignSystem.Spacing.xl   // 32pt
DesignSystem.Spacing.xxl  // 48pt
```

### Corner Radius
```swift
DesignSystem.CornerRadius.sm  // 8pt
DesignSystem.CornerRadius.md  // 12pt
DesignSystem.CornerRadius.lg  // 16pt
DesignSystem.CornerRadius.xl  // 24pt
```

### Colors
```swift
DesignSystem.Colors.background
DesignSystem.Colors.secondaryBackground
DesignSystem.Colors.tertiaryBackground
DesignSystem.Colors.accent
```

### Shadows
```swift
DesignSystem.Shadow.light
DesignSystem.Shadow.medium
DesignSystem.Shadow.heavy
```

---

## Accessibility

All components include:
- VoiceOver labels
- Minimum 44pt tap targets
- High contrast support
- Dynamic Type support
- Semantic colors (adapt to dark mode)

---

## Best Practices

1. **Always use design tokens** instead of hardcoded values
2. **Leverage component library** - don't reinvent
3. **Test in both light and dark mode**
4. **Verify VoiceOver navigation**
5. **Use semantic colors** that adapt to themes
6. **Keep components simple** and focused

---

## Adding New Components

When adding new components:

1. Follow existing naming convention (`SS` prefix)
2. Add to `/Views/Components/` directory
3. Document in this file
4. Include accessibility labels
5. Support both light/dark modes
6. Use design system tokens
7. Add example usage

---

## Migration from Old Code

If migrating existing views:

```swift
// Old
Button("Click Me") { }
    .padding()
    .background(Color.blue)
    .cornerRadius(8)

// New
SSButton("Click Me", style: .primary) { }
```

Benefits:
- Consistency
- Less code
- Automatic accessibility
- Themeable
- Maintainable
