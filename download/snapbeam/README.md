# SnapBeam - Send Moments Instantly

<p align="center">
  <strong>Send moments. Instantly live on your loved one's home screen.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Package%20ID-app.snapbeam.photo-blue?style=for-the-badge" alt="Package ID">
</p>

---

## 📱 App Store Ready

SnapBeam is fully configured for deployment to both:
- **Google Play Store** (Android)
- **Apple App Store** (iOS)

### Unique Package ID
- **Android**: `app.snapbeam.photo`
- **iOS**: `app.snapbeam.photo`

This package ID is unique and ready for store submission.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.2+
- Android Studio (for Android)
- Xcode 15+ (for iOS, macOS only)
- CocoaPods (for iOS)

### Installation

```bash
# Clone or download the project
cd flutter-app

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on device
flutter run
```

### Build for Release

```bash
# Android (AAB for Play Store)
flutter build appbundle --release

# Android (APK for direct install)
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

---

## 📁 Project Structure

```
flutter-app/
├── android/                      # Android native configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml    # Permissions & app config
│   │   │   ├── kotlin/app/snapbeam/photo/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── SnapBeamWidgetProvider.kt
│   │   │   │   └── BootReceiver.kt
│   │   │   └── res/
│   │   │       ├── values/
│   │   │       ├── layout/
│   │   │       └── xml/
│   │   ├── build.gradle           # App-level build config
│   │   └── proguard-rules.pro     # ProGuard rules
│   ├── build.gradle               # Project-level build config
│   ├── gradle.properties
│   └── settings.gradle
│
├── ios/                           # iOS native configuration
│   ├── Runner/
│   │   ├── Info.plist             # iOS permissions & config
│   │   └── PrivacyInfo.xcprivacy  # Privacy manifest (iOS 17+)
│   ├── Runner.xcworkspace/
│   └── Podfile
│
├── lib/                           # Flutter code
│   ├── main.dart                  # App entry point
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── widget_setup_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── settings_screen.dart
│   │   └── premium_screen.dart
│   ├── services/
│   │   ├── backend_service.dart
│   │   ├── widget_service.dart
│   │   └── usage_service.dart
│   ├── providers/
│   │   ├── connection_provider.dart
│   │   └── theme_provider.dart
│   ├── widgets/
│   │   ├── connection_code_display.dart
│   │   ├── join_connection_dialog.dart
│   │   └── photo_widget.dart
│   ├── l10n/                      # Localization
│   │   ├── app_en.arb
│   │   ├── app_ar.arb
│   │   └── app_es.arb
│   └── utils/
│       ├── app_theme.dart
│       └── image_compress.dart
│
├── assets/
│   ├── images/
│   └── fonts/
│
├── pubspec.yaml                   # Dependencies & config
├── analysis_options.yaml          # Linting rules
└── l10n.yaml                      # Localization config
```

---

## 📲 App Store Compliance

### Android Permissions
| Permission | Purpose |
|------------|---------|
| `INTERNET` | API communication |
| `CAMERA` | Take photos |
| `READ_EXTERNAL_STORAGE` | Select photos from gallery |
| `WRITE_EXTERNAL_STORAGE` | Save received photos |
| `READ_MEDIA_IMAGES` | Access photos on Android 13+ |
| `VIBRATE` | Haptic feedback |
| `RECEIVE_BOOT_COMPLETED` | Widget updates after restart |

### iOS Permissions
| Permission | Key | Description |
|------------|-----|-------------|
| Camera | `NSCameraUsageDescription` | Take photos |
| Photo Library | `NSPhotoLibraryUsageDescription` | Select photos |
| Photo Library Add | `NSPhotoLibraryAddUsageDescription` | Save photos |

### Privacy Manifest (iOS 17+)
- Includes `PrivacyInfo.xcprivacy`
- All API usage documented
- No tracking enabled
- Data collection disclosed

---

## 🎨 Configuration

### App Icon
Place your app icon at:
- `assets/images/app_icon.png` (1024x1024)
- `assets/images/app_icon_foreground.png` (adaptive icon)

Run: `flutter pub run flutter_launcher_icons`

### Splash Screen
Configure in `pubspec.yaml` under `flutter_native_splash`

Run: `flutter pub run flutter_native_splash:create`

### Backend API
Update the API URL in `lib/services/backend_service.dart`:
```dart
static const String baseUrl = 'https://your-worker.workers.dev';
```

---

## 🌍 Localization

Supported languages:
- 🇺🇸 English (`en`)
- 🇸🇦 Arabic (`ar`)
- 🇪🇸 Spanish (`es`)

To add a new language:
1. Create `lib/l10n/app_XX.arb`
2. Copy and translate from `app_en.arb`
3. Add locale to `main.dart`
4. Run `flutter gen-l10n`

---

## 🔒 Security Features

- **No personal data collection**
- **No analytics/tracking**
- **No user accounts**
- **End-to-end HTTPS encryption**
- **Automatic data cleanup**
- **ProGuard/R8 obfuscation** (Android)
- **App Transport Security** (iOS)

---

## 📦 Deployment

### Google Play Store
See: [STORE_DEPLOYMENT.md](docs/STORE_DEPLOYMENT.md)

1. Create Google Play Developer account ($25)
2. Build signed AAB
3. Upload to Play Console
4. Complete store listing
5. Submit for review

### Apple App Store
See: [STORE_DEPLOYMENT.md](docs/STORE_DEPLOYMENT.md)

1. Enroll in Apple Developer Program ($99/year)
2. Create App ID and certificates
3. Archive in Xcode
4. Upload to App Store Connect
5. Complete store listing
6. Submit for review

---

## 📄 Documentation

| File | Description |
|------|-------------|
| [README.md](README.md) | This file |
| [STORE_DEPLOYMENT.md](docs/STORE_DEPLOYMENT.md) | Step-by-step store deployment |
| [APP_STORE_METADATA.md](docs/APP_STORE_METADATA.md) | Store listing content |
| [PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md) | Privacy policy |
| [TERMS_OF_SERVICE.md](docs/TERMS_OF_SERVICE.md) | Terms of service |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Technical deployment |

---

## 🔧 Backend

See: `cloudflare-workers/` directory

The backend runs on Cloudflare Workers (free tier):
- KV storage for connections
- R2 for image storage
- REST API endpoints

### API Endpoints
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/create` | POST | Create connection |
| `/update` | POST | Update photo |
| `/latest` | GET | Get latest photo |
| `/upload` | POST | Upload to R2 |

---

## 🛠 Development

### Run Tests
```bash
flutter test
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
dart format .
```

### Check Dependencies
```bash
flutter pub outdated
```

---

## 💰 Monetization

| Plan | Daily Sends | Price |
|------|-------------|-------|
| Free | 2/day | $0 |
| Premium (Coming Soon) | Unlimited | $2.99/month or $19.99/year |

### Premium Features (Coming Soon)
- ✨ Unlimited photo sends
- 📷 HD quality photos
- 📁 30-day photo history
- 🎨 Custom widget themes
- 👥 Multiple connections
- ⚡ Priority support

---

## 💰 Cost (Free Tier)

| Service | Free Limit |
|---------|------------|
| Cloudflare Workers | 100,000 requests/day |
| Cloudflare KV | 100,000 reads/day |
| Cloudflare R2 | 10GB storage |
| Google Play | $25 one-time |
| Apple App Store | $99/year |

---

## 📝 License

MIT License - See [LICENSE](LICENSE) file.

---

## 🙏 Acknowledgments

- Flutter team
- Cloudflare
- All contributors

---

<p align="center">
  Made with ❤️ for families everywhere
</p>
