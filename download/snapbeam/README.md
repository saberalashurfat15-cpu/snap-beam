# SnapBeam - Send Moments Instantly

<p align="center">
  <strong>Send moments. Instantly live on your loved one's home screen.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white" alt="Cloudflare">
  <img src="https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white" alt="Next.js">
</p>

---

## 📱 Overview

SnapBeam is a revolutionary photo-sharing app that lets you send photos instantly to your loved ones' home screen widgets. No accounts, no login friction—just simple private connection codes.

### Key Features

- **Instant Photo Sharing**: Capture and send photos in seconds
- **Home Screen Widgets**: Photos appear directly on home screen widgets
- **No Accounts Required**: Just share a connection code
- **Multi-Language Support**: English, Arabic, Spanish
- **Cross-Platform**: Works on both iOS and Android
- **Free Backend**: Powered by Cloudflare Workers

---

## 🏗 Architecture

```
┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │     │   Flutter App   │
│   (Sender)      │     │   (Receiver)    │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │   Cloudflare Workers  │
         │   (REST API)          │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │   Cloudflare KV + R2  │
         │   (Storage)           │
         └───────────────────────┘
```

---

## 📁 Project Structure

```
snapbeam/
├── flutter-app/                 # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── screens/            # UI screens
│   │   │   ├── welcome_screen.dart
│   │   │   ├── camera_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/            # Reusable widgets
│   │   │   ├── connection_code_display.dart
│   │   │   └── join_connection_dialog.dart
│   │   ├── services/           # Backend & storage
│   │   │   ├── backend_service.dart
│   │   │   └── widget_service.dart
│   │   ├── providers/          # State management
│   │   │   ├── connection_provider.dart
│   │   │   └── theme_provider.dart
│   │   ├── l10n/               # Localization
│   │   │   ├── app_en.arb
│   │   │   ├── app_ar.arb
│   │   │   └── app_es.arb
│   │   └── utils/              # Utilities
│   │       ├── app_theme.dart
│   │       └── image_compress.dart
│   └── pubspec.yaml
│
├── cloudflare-workers/          # Backend API
│   ├── worker.js               # Main worker code
│   ├── wrangler.toml           # Cloudflare config
│   └── package.json
│
├── docs/                        # Documentation
│   └── DEPLOYMENT.md
│
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.2+
- Node.js 18+
- Cloudflare account (free tier works)

### 1. Deploy the Backend

```bash
# Navigate to cloudflare workers
cd cloudflare-workers

# Install dependencies
npm install

# Login to Cloudflare
npx wrangler login

# Create KV namespace
npx wrangler kv:namespace create SNAPBEAM_KV

# Create R2 bucket (optional, for image storage)
npx wrangler r2 bucket create snapbeam-photos

# Update wrangler.toml with your IDs

# Deploy
npx wrangler deploy
```

### 2. Build the Flutter App

```bash
# Navigate to flutter app
cd flutter-app

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on device
flutter run

# Build for release
flutter build apk --release     # Android
flutter build ios --release     # iOS
```

### 3. Configure the API URL

Edit `lib/services/backend_service.dart` and update:

```dart
static const String baseUrl = 'https://your-worker.your-subdomain.workers.dev';
```

---

## 🔌 API Endpoints

### Create Connection

```http
POST /create
Response: { "connection_id": "X7K9LM2Q" }
```

### Update Photo

```http
POST /update
Body: {
  "connection_id": "X7K9LM2Q",
  "photo_base64": "...",
  "caption": "Good morning!"
}
```

### Get Latest Photo

```http
GET /latest?connection_id=X7K9LM2Q
Response: {
  "last_photo_base64": "...",
  "last_caption": "Good morning!",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

## 🌍 Localization

The app supports multiple languages:

| Language | Code | File |
|----------|------|------|
| English | `en` | `app_en.arb` |
| Arabic | `ar` | `app_ar.arb` |
| Spanish | `es` | `app_es.arb` |

To add a new language:

1. Create `lib/l10n/app_XX.arb`
2. Copy translations from `app_en.arb`
3. Translate all values
4. Run `flutter gen-l10n`

---

## 📱 Widget Setup

### Android

1. Long press on home screen
2. Tap "Widgets"
3. Find "SnapBeam"
4. Drag to home screen

### iOS

1. Long press on home screen
2. Tap the "+" button
3. Find "SnapBeam"
4. Add widget

---

## 🔒 Security

- Connection codes are 8-character random strings
- No personal data is stored
- Photos are stored temporarily in KV (with base64) or R2
- No authentication required

---

## 💰 Cost (Cloudflare Free Tier)

| Service | Free Limit |
|---------|------------|
| Workers | 100,000 requests/day |
| KV Reads | 100,000/day |
| KV Writes | 1,000/day |
| R2 Storage | 10GB |
| R2 Operations | 1M Class A, 10M Class B/month |

For most personal use cases, this is completely free!

---

## 🎨 Design System

### Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#6366F1` | Buttons, links |
| Secondary | `#EC4899` | Accents, highlights |
| Tertiary | `#14B8A6` | Secondary actions |

### Typography

- Primary font: Poppins
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

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

### Build for Web (Demo)

```bash
flutter build web
```

---

## 📄 License

MIT License - Feel free to use, modify, and distribute.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Cloudflare for the free edge computing platform
- All contributors and testers

---

<p align="center">
  Made with ❤️ for families everywhere
</p>
