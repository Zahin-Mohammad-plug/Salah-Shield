# Family Controls Setup Guide

## Required Configuration for Family Controls API

To use the Family Controls API for app blocking, you need to configure the following in Xcode:

### 1. Add Family Controls Capability

1. Open your project in Xcode
2. Select your **SalahShield** target
3. Go to **Signing & Capabilities** tab
4. Click the **"+ Capability"** button
5. Search for and add **"Family Controls"**

This will automatically:
- Add the `com.apple.developer.family-controls` entitlement
- Configure the necessary settings

### 2. Info.plist Configuration

The following keys have already been added to `Info.plist`:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>SalahShield uses Screen Time to temporarily block distracting apps and websites during prayer times, helping you stay focused on worship.</string>
<key>NSFamilyControls</key>
<true/>
```

### 3. Required Settings

#### Minimum iOS Version
- Family Controls API requires **iOS 15.0+**
- Ensure your deployment target is set to iOS 15.0 or later

#### App Group (Optional)
If you plan to share blocking state across app extensions or widgets, you'll need an App Group:
1. In **Signing & Capabilities**
2. Add **"App Groups"** capability
3. Create a new group: `group.com.yourcompany.salahshield`

### 4. Testing

⚠️ **Important**: Family Controls API has restrictions:
- Must be tested on a **physical device** (not simulator)
- Requires **Screen Time** to be enabled in Settings
- User must grant permission through Settings → Screen Time → App Limits

### 5. Code Requirements

Already implemented in the codebase:
- ✅ `ScreenTimeService` with `@MainActor` isolation
- ✅ `FamilyActivityPicker` integration in `BlocklistDetailView`
- ✅ Authorization request flow
- ✅ Blocking/unblocking functionality

### 6. Build Settings Check

Verify these are set correctly:
- **Swift Language Version**: Swift 5.5+
- **Concurrency**: Enabled
- **Minimum Deployment**: iOS 15.0+

### Troubleshooting

**Issue**: "FamilyControls framework not found"
- Solution: Ensure you're on Xcode 13+ and iOS 15+ deployment target

**Issue**: Authorization always denied
- Solution: Must be tested on physical device, not simulator

**Issue**: Apps not blocking
- Solution: Check that `isActive` is `true` and authorization status is `.approved`

---

## Current Implementation Status

✅ Screen Time Service integrated  
✅ Family Activity Picker UI  
✅ Authorization flow  
✅ Automatic blocking during prayer windows  
✅ Info.plist entries added  

🔧 **Still needed**: Add Family Controls capability in Xcode project settings


