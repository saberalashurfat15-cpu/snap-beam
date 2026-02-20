# iOS Widget Setup Guide

This guide explains how to set up the SnapBeam widget for iOS.

## ⚠️ Important: Xcode Setup Required

The iOS widget extension **must be added in Xcode**. Follow these steps:

### Step 1: Open the iOS Project in Xcode

```bash
cd flutter-app
open ios/Runner.xcworkspace
```

### Step 2: Add Widget Extension Target

1. In Xcode, go to **File → New → Target**
2. Select **Widget Extension**
3. Enter product name: `SnapBeamWidget`
4. Uncheck "Include Configuration Intent" (we use the default)
5. Click **Finish**
6. When asked to activate the new scheme, click **Activate**

### Step 3: Configure App Groups

1. Select the **Runner** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **App Groups**
5. Add group: `group.app.snapbeam.photo`

6. Select the **SnapBeamWidget** target
7. Repeat steps 2-5 to add the same App Group

### Step 4: Replace Widget Code

Replace the contents of `SnapBeamWidget.swift` with the code from:
`ios/SnapBeamWidget/SnapBeamWidget.swift`

### Step 5: Update Info.plist

Make sure `ios/Runner/Info.plist` includes:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```

### Step 6: Add Entitlements

1. Add `ios/Runner/Runner.entitlements` to the Runner target
2. Add `ios/SnapBeamWidget/SnapBeamWidgetExtension.entitlements` to the widget target

### Step 7: Build and Run

```bash
flutter build ios --debug
flutter run
```

---

## 📁 Files Included

| File | Purpose |
|------|---------|
| `ios/Runner/AppDelegate.swift` | Home Widget callback registration |
| `ios/Runner/Runner.entitlements` | App Groups configuration |
| `ios/SnapBeamWidget/SnapBeamWidget.swift` | Widget UI implementation |
| `ios/SnapBeamWidget/Info.plist` | Widget extension configuration |
| `ios/SnapBeamWidget/SnapBeamWidgetExtension.entitlements` | Widget App Groups |

---

## 🔧 Troubleshooting

### Error: "Export Widget doesn't exist in target module"

This error means the Widget Extension hasn't been properly added in Xcode. Follow Step 2 above to add the widget extension target.

### Widget not updating

1. Check App Groups are configured for both targets
2. Check the group name matches: `group.app.snapbeam.photo`
3. Make sure `AppDelegate.swift` includes the HomeWidgetPlugin setup

### Build errors

1. Clean the build folder: **Product → Clean Build Folder**
2. Delete derived data: **Xcode → Settings → Locations → Derived Data**
3. Run `flutter clean` then `flutter pub get`

---

## 📱 Testing the Widget

1. Run the app on an iOS device or simulator
2. Long press on the home screen
3. Tap the **+** button
4. Search for **SnapBeam**
5. Add the widget
6. Send a photo from another device to see it appear

---

## 💡 Notes

- The widget updates every 5 minutes automatically
- You can also pull down on the widget to refresh manually
- Photos are stored as base64 in shared UserDefaults
