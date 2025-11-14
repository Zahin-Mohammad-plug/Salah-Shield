# Bug Report - SalahShield App

## Critical Bugs

### 1. Missing Color Assets (Runtime Crash Risk)
**Location:** `DesignSystem.swift` lines 14-21
**Issue:** DesignSystem references color assets ("Background", "SecondaryBackground", "CardBackground", etc.) that don't exist in Assets.xcassets
**Impact:** App will crash at runtime when these colors are accessed
**Files Affected:** All views using DesignSystem.Colors.background, secondaryBackground, etc.

### 2. NextPrayer is nil after all prayers pass
**Location:** `PrayerTimeService.swift` line 198-203, `HomeView.swift` line 98
**Issue:** When all prayers for the day have passed (e.g., after Isha), `nextPrayer` becomes nil and the NextPrayerCard disappears
**Impact:** User sees empty home screen at night with no indication of next prayer (tomorrow's Fajr)
**Fix Needed:** Calculate next day's Fajr when all today's prayers have passed

### 3. TimeUntil shows negative values
**Location:** `HomeView.swift` line 179-189
**Issue:** If `prayer.time` is in the past, `timeUntil` calculates negative time components
**Impact:** Shows incorrect time remaining or negative values

### 4. Timer day change detection logic bug
**Location:** `AppState.swift` line 181
**Issue:** Timer only checks if hour == 0 AND minute < 2, missing 99% of the first hour of the day
**Impact:** If user opens app between 12:02 AM and 1:00 AM, prayer times won't refresh until next midnight check

### 5. Location updates stop after first fix
**Location:** `LocationService.swift` line 132
**Issue:** `stopUpdatingLocation()` is called immediately after first location update
**Impact:** App won't detect location changes when user travels (defeats travel mode feature)

### 6. Prayer array mutation doesn't trigger proper updates
**Location:** `ScheduleView.swift` line 67
**Issue:** Direct mutation of `@Published` array element may not trigger SwiftUI updates properly
**Impact:** UI might not reflect buffer changes immediately

### 7. BufferEditorSheet binding issue
**Location:** `ScheduleView.swift` lines 60-63
**Issue:** Binding closure captures `editingPrayer` which may be stale; using a computed binding pattern incorrectly
**Impact:** Changes to buffer values might not save correctly

## Medium Priority Issues

### 8. Unused state variables
**Location:** Multiple files
**Issues:**
- `HomeView.swift` line 14: `showLocationBanner` is never used
- `SettingsView.swift` line 15: `showAbout` is never used
- `LocationSetupView.swift` line 16: `showLocationError` is never used

### 9. Missing nextPrayer update on day change
**Location:** `AppState.swift` line 182
**Issue:** When prayer times refresh, `updateNextPrayer()` is called, but if refresh happens during the day change window (midnight), it might use stale `Date()` from before refresh

### 10. No handling for calculation errors
**Location:** `PrayerTimeService.swift` line 117-118
**Issue:** If Adhan calculation fails, empty array is returned silently; `calculationError` is never set
**Impact:** User sees no prayers without knowing why

## Minor Issues

### 11. Timer continues running unnecessarily
**Location:** `AppState.swift` line 174
**Issue:** Timer runs every 60 seconds just to check for midnight; could be optimized
**Note:** This is acceptable but inefficient

### 12. Hardcoded debug code in production
**Location:** `PrayerTimeService.swift` lines 73-109
**Issue:** Extensive debug print statements should be removed or conditional
**Impact:** Console spam, performance impact

### 13. Missing validation for prayer buffer ranges
**Location:** `ScheduleView.swift` BufferEditorSheet
**Issue:** No validation to ensure bufferBefore + bufferAfter makes sense
**Impact:** User could set extreme values

---

## Summary
- **Critical:** 7 bugs that could cause crashes or broken functionality
- **Medium:** 3 issues affecting user experience
- **Minor:** 3 code quality issues

Total: 13 issues identified


