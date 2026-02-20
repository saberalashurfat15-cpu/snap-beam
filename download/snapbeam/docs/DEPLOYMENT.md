# SnapBeam Deployment Guide

This guide walks you through deploying the complete SnapBeam application.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Cloudflare Workers Setup](#cloudflare-workers-setup)
3. [Flutter App Configuration](#flutter-app-configuration)
4. [iOS Widget Setup](#ios-widget-setup)
5. [Android Widget Setup](#android-widget-setup)
6. [Testing](#testing)
7. [Production Checklist](#production-checklist)

---

## Prerequisites

### Required Accounts

- [Cloudflare Account](https://dash.cloudflare.com/sign-up) (Free tier works)
- [Apple Developer Account](https://developer.apple.com) ($99/year for iOS)
- [Google Play Console](https://play.google.com/console) ($25 one-time for Android)

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| Node.js | 18+ | Running Wrangler CLI |
| Flutter | 3.2+ | Mobile app development |
| Xcode | 15+ | iOS builds (macOS only) |
| Android Studio | Latest | Android builds |
| VS Code | Latest | Recommended IDE |

---

## Cloudflare Workers Setup

### Step 1: Install Wrangler

```bash
npm install -g wrangler
```

### Step 2: Login to Cloudflare

```bash
wrangler login
```

This will open a browser window for authentication.

### Step 3: Create KV Namespace

```bash
cd cloudflare-workers
wrangler kv:namespace create SNAPBEAM_KV
```

Copy the output ID and update `wrangler.toml`:

```toml
[[kv_namespaces]]
binding = "SNAPBEAM_KV"
id = "your-kv-namespace-id-here"
```

### Step 4: Create R2 Bucket (Optional)

For larger image storage:

```bash
wrangler r2 bucket create snapbeam-photos
```

Update `wrangler.toml`:

```toml
[[r2_buckets]]
binding = "SNAPBEAM_R2"
bucket_name = "snapbeam-photos"
```

### Step 5: Configure Custom Domain (Optional)

```bash
# Add route in wrangler.toml
[[routes]]
pattern = "api.snapbeam.app/*"
zone_name = "snapbeam.app"
```

### Step 6: Deploy

```bash
wrangler deploy
```

Note your worker URL: `https://snapbeam-api.your-subdomain.workers.dev`

### Step 7: Test the API

```bash
# Test health endpoint
curl https://your-worker.workers.dev/health

# Create a connection
curl -X POST https://your-worker.workers.dev/create

# Get latest photo
curl "https://your-worker.workers.dev/latest?connection_id=TEST1234"
```

---

## Flutter App Configuration

### Step 1: Update API URL

Edit `lib/services/backend_service.dart`:

```dart
static const String baseUrl = 'https://snapbeam-api.your-subdomain.workers.dev';
```

### Step 2: Install Dependencies

```bash
cd flutter-app
flutter pub get
```

### Step 3: Generate Localization Files

```bash
flutter gen-l10n
```

### Step 4: Configure App Icons

Install flutter_launcher_icons:

```bash
flutter pub add dev:flutter_launcher_icons
```

Create `flutter_launcher_icons.yaml`:

```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
```

Run:

```bash
flutter pub run flutter_launcher_icons
```

### Step 5: Run the App

```bash
flutter run
```

---

## iOS Widget Setup

### Step 1: Create Widget Extension

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select "Widget Extension"
4. Name it "SnapBeamWidget"
5. Ensure "Include Configuration Intent" is unchecked

### Step 2: Configure App Groups

1. Select Runner target → Signing & Capabilities
2. Add "App Groups" capability
3. Add group: `group.com.snapbeam.app`
4. Repeat for SnapBeamWidget target

### Step 3: Implement Widget

Replace `SnapBeamWidget.swift` with:

```swift
import WidgetKit
import SwiftUI

struct SnapBeamWidgetEntry: TimelineEntry {
    let date: Date
    let photoData: Data?
    let caption: String?
}

struct SnapBeamWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnapBeamWidgetEntry {
        SnapBeamWidgetEntry(date: Date(), photoData: nil, caption: "Waiting for photo...")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SnapBeamWidgetEntry) -> Void) {
        let entry = SnapBeamWidgetEntry(date: Date(), photoData: nil, caption: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SnapBeamWidgetEntry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.snapbeam.app")
        let photoBase64 = sharedDefaults?.string(forKey: "last_photo")
        let caption = sharedDefaults?.string(forKey: "last_caption")
        
        var photoData: Data?
        if let base64 = photoBase64 {
            photoData = Data(base64Encoded: base64)
        }
        
        let entry = SnapBeamWidgetEntry(date: Date(), photoData: photoData, caption: caption)
        
        // Refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct SnapBeamWidgetView: View {
    let entry: SnapBeamWidgetEntry
    
    var body: some View {
        if let data = entry.photoData, let uiImage = UIImage(data: data) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                
                if let caption = entry.caption, !caption.isEmpty {
                    VStack {
                        Spacer()
                        Text(caption)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.6))
                    }
                }
            }
        } else {
            VStack {
                Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("Waiting for photo...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

@main
struct SnapBeamWidget: Widget {
    let kind: String = "SnapBeamWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnapBeamWidgetProvider()) { entry in
            SnapBeamWidgetView(entry: entry)
        }
        .configurationDisplayName("SnapBeam")
        .description("See the latest shared photo.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

### Step 4: Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
</array>
```

---

## Android Widget Setup

### Step 1: Create Widget Provider

Create `android/app/src/main/kotlin/com/snapbeam/app/SnapBeamWidgetProvider.kt`:

```kotlin
package com.snapbeam.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.util.Base64
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SnapBeamWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.snapbeam_widget)
        
        // Get data from HomeWidget
        val widgetData = HomeWidgetPlugin.getData(context)
        val photoBase64 = widgetData.getString("last_photo", null)
        val caption = widgetData.getString("last_caption", "")
        
        if (photoBase64 != null) {
            try {
                val bytes = Base64.decode(photoBase64, Base64.DEFAULT)
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                views.setImageViewBitmap(R.id.widget_image, bitmap)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        
        views.setTextViewText(R.id.widget_caption, caption)
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
```

### Step 2: Create Widget Layout

Create `android/app/src/main/res/layout/snapbeam_widget.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    
    <ImageView
        android:id="@+id/widget_image"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:scaleType="centerCrop"
        android:src="@drawable/ic_launcher_foreground" />
    
    <TextView
        android:id="@+id/widget_caption"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:background="#80000000"
        android:padding="8dp"
        android:textColor="@android:color/white"
        android:textSize="12sp" />
</FrameLayout>
```

### Step 3: Configure Widget in Manifest

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<receiver android:name=".SnapBeamWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/snapbeam_widget_info" />
</receiver>
```

### Step 4: Create Widget Info

Create `android/app/src/main/res/xml/snapbeam_widget_info.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="180dp"
    android:minHeight="180dp"
    android:updatePeriodMillis="300000"
    android:initialLayout="@layout/snapbeam_widget"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen"
    android:previewImage="@drawable/ic_launcher_foreground" />
```

---

## Testing

### API Testing

```bash
# Create connection
curl -X POST https://your-api.workers.dev/create

# Update photo (use small test image)
BASE64_DATA=$(base64 -w 0 test_image.jpg)
curl -X POST https://your-api.workers.dev/update \
  -H "Content-Type: application/json" \
  -d "{\"connection_id\":\"TEST1234\",\"photo_base64\":\"$BASE64_DATA\",\"caption\":\"Test photo\"}"

# Get latest
curl "https://your-api.workers.dev/latest?connection_id=TEST1234"
```

### Widget Testing

1. Install app on device
2. Create or join a connection
3. Add widget to home screen
4. Send a photo from another device
5. Verify widget updates within 5 minutes

---

## Production Checklist

### Before Launch

- [ ] Update API URL to production endpoint
- [ ] Configure proper CORS headers
- [ ] Set up error tracking (e.g., Sentry)
- [ ] Add rate limiting to worker
- [ ] Test on multiple devices
- [ ] Verify widget functionality
- [ ] Test localization
- [ ] Create app store screenshots
- [ ] Write privacy policy

### App Store Submission

#### iOS

- [ ] Apple Developer account active
- [ ] App ID configured
- [ ] Certificates and profiles set up
- [ ] Build archived and uploaded
- [ ] App Store listing complete

#### Android

- [ ] Google Play Console account
- [ ] App signing key generated
- [ ] AAB built and uploaded
- [ ] Store listing complete

### Post-Launch

- [ ] Monitor worker analytics
- [ ] Set up alerts for errors
- [ ] Gather user feedback
- [ ] Plan feature updates

---

## Troubleshooting

### Widget Not Updating

1. Check App Group is configured correctly (iOS)
2. Verify HomeWidget plugin is initialized
3. Check background refresh is enabled
4. Test API connectivity

### Photo Upload Fails

1. Check image size (should be < 5MB)
2. Verify base64 encoding
3. Check worker logs: `wrangler tail`

### iOS Build Fails

1. Run `pod install` in ios directory
2. Check Xcode version compatibility
3. Verify signing configuration

### Android Build Fails

1. Clean build: `flutter clean`
2. Check Gradle version
3. Verify SDK versions

---

## Support

For issues and feature requests, please open an issue on GitHub.
