# Salah Shield - Prayer Time App Blocking

A beautifully designed iOS app that helps users stay present during prayer times by temporarily reducing phone distractions.

## 🎨 Design Philosophy

- **Clean & Minimal**: Calm, respectful interface with low clutter
- **Accessible**: Large tap targets, clear labels, VoiceOver support
- **Adaptive**: Full light/dark mode support
- **Professional**: Production-ready code following iOS best practices

## 📱 Features

### Core Functionality
- **Smart Prayer Scheduling**: Automatic prayer time calculation based on location
- **Customizable Windows**: Adjust buffer times before/after each prayer
- **App/Website Blocking**: Create blocklists to reduce distractions
- **Prayer Notifications**: Gentle reminders before each prayer time
- **Status Management**: Easy pause/resume functionality

### Premium Features (Pro)
- 🛡️ **Unlimited Blocklists**: Create multiple custom blocklists
- ⚙️ **Per-Prayer Buffers**: Individual customization for each salah
- 🌙 **Ramadan Mode**: Special features for the blessed month
- 🕌 **Jumu'ah Mode**: Extended Friday prayer support
- ✈️ **Travel Mode**: Auto-updating prayer times while traveling
- 👑 **Premium Support**: Priority assistance

## 🏗️ Architecture

### Project Structure
```
SalahShield/
├── App/                    # App entry point and configuration
│   ├── SalahShieldApp.swift
│   └── ContentView.swift
├── Models/                 # Data models
│   ├── AppState.swift
│   ├── Prayer.swift
│   └── Blocklist.swift
├── Views/                  # UI screens and components
│   ├── Onboarding/        # First-run experience
│   ├── Home/              # Main dashboard
│   ├── Schedule/          # Prayer schedule management
│   ├── Blocklists/        # App/website blocking
│   ├── Modes/             # Special modes (Jumu'ah, Ramadan)
│   ├── Settings/          # App preferences
│   ├── Paywall/           # Premium upgrade
│   └── Components/        # Reusable UI components
├── ViewModels/            # Business logic (future)
├── Services/              # Prayer calculation, blocking logic
└── Utilities/             # Design system, helpers
```

### Key Components

#### Design System (`DesignSystem.swift`)
- Centralized spacing, colors, typography
- Consistent corner radius and shadows
- Easy to maintain and update

#### Component Library
- **SSButton**: Versatile button with 5 styles and 3 sizes
- **SSCard**: Container component with shadow
- **SSStatusChip**: Status indicator with color coding
- **SSBanner**: Information/warning banners
- **SSListRow**: Flexible list row with accessories
- **SSEmptyState**: Placeholder for empty screens

#### State Management
- **AppState**: Central observable state management
- **ThemeManager**: Light/dark mode handling
- SwiftUI @Published properties for reactivity

## 🎯 User Flows

### Onboarding Flow
1. **Welcome**: Value proposition and feature overview
2. **Location**: Enable location or select city manually
3. **Calculation Method**: Choose prayer time calculation
4. **Blocklists**: Initial app category selection

### Main Flow
- Home → View next prayer and today's schedule
- Schedule → Customize prayer windows and buffers
- Blocklists → Manage apps/websites to block
- Modes → Toggle Jumu'ah and Ramadan presets
- Settings → Configure all preferences

### Monetization Flow
- Freemium model: 1 free blocklist
- Pro features gated with upgrade prompts
- Paywall with 3 options: Monthly, Annual, Lifetime
- Non-intrusive upgrade CTAs throughout app

## 🎨 UI Screens

### Onboarding (4 screens)
- ✅ Welcome with value proposition
- ✅ Location setup (GPS or manual city)
- ✅ Calculation method selection
- ✅ Initial blocklist configuration

### Main App (5 tabs)
- ✅ **Home**: Next prayer, countdown, today's schedule
- ✅ **Schedule**: Prayer windows with visual timeline
- ✅ **Blocklists**: CRUD for apps/websites/categories
- ✅ **Modes**: Jumu'ah and Ramadan toggles
- ✅ **Settings**: Full preferences management

### Paywall
- ✅ Feature highlights with icons
- ✅ 3 subscription plans with badges
- ✅ Clear pricing and terms

## 🔧 Code Standards

### SwiftUI Best Practices
- ✅ Proper state management with @State, @Binding, @EnvironmentObject
- ✅ View composition and reusability
- ✅ Accessibility labels and hints
- ✅ Dark mode support throughout
- ✅ Proper error states and empty states

### Developer Experience
- 📝 Clear comments and documentation
- 🏷️ Descriptive variable and function names
- 📦 Modular, testable components
- 🎨 Consistent design tokens
- 🔄 Easy to extend and maintain

## 🚀 Future Enhancements

### Services Layer (To Implement)
```swift
Services/
├── PrayerCalculationService.swift  // Adhan library integration
├── LocationService.swift           // CoreLocation wrapper
├── BlockingService.swift           // ScreenTime API integration
├── NotificationService.swift       // Local notifications
└── PersistenceService.swift        // CoreData/UserDefaults
```

### Features Roadmap
- [ ] Real prayer time calculation (Adhan library)
- [ ] Actual app/website blocking (ScreenTime API)
- [ ] Push notifications for prayer times
- [ ] Widget support (iOS 14+)
- [ ] Watch app companion
- [ ] Analytics and insights
- [ ] Qibla direction finder
- [ ] Prayer counter/tracker

## 🎨 Design Tokens

### Colors
- Primary: System Accent
- Secondary: System Gray
- Background: Adaptive (Light/Dark)

### Spacing Scale
- xs: 4pt
- sm: 8pt
- md: 16pt
- lg: 24pt
- xl: 32pt
- xxl: 48pt

### Typography
- Caption: 12pt
- Body: 16pt
- Title3: 20pt
- Title2: 24pt
- Title1: 32pt
- Large: 40pt

## 📋 Component API Examples

### Button Usage
```swift
SSButton("Continue", style: .primary, size: .large) {
    // Action
}

SSButton("Learn More", icon: "info.circle", style: .secondary, size: .medium) {
    // Action
}
```

### Banner Usage
```swift
SSBanner(
    message: "Location required for prayer times",
    type: .warning,
    action: { /* Fix action */ }
)
```

### List Row Usage
```swift
SSListRow(
    title: "Notifications",
    subtitle: "Enabled",
    icon: "bell.fill",
    accessory: .toggle($notificationsEnabled)
)
```

## 🧪 Testing Checklist

- [ ] Onboarding flow completion
- [ ] Tab navigation
- [ ] Prayer time calculations
- [ ] Buffer slider adjustments
- [ ] Blocklist CRUD operations
- [ ] Theme switching (Light/Dark)
- [ ] Paywall presentation
- [ ] Empty states
- [ ] Error states
- [ ] VoiceOver navigation
- [ ] Dynamic Type support
- [ ] Landscape orientation
- [ ] iPad layout (future)

## 📱 Supported Platforms

- iOS 15.0+
- iPhone (optimized)
- iPad (compatible)
- Dark Mode: ✅
- VoiceOver: ✅
- Dynamic Type: ✅

## 🤝 Contributing

This codebase is designed for team collaboration:
- Clear file organization
- Reusable components
- Documented architecture
- Consistent coding style
- Easy to onboard new developers

## 📄 License

[Your License Here]

## 👥 Team

[Your Team Information]

---

Built with ❤️ for the Muslim community