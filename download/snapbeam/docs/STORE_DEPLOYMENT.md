# SnapBeam - Store Deployment Guide

Complete guide for deploying SnapBeam to Google Play Store and Apple App Store.

---

## 📋 Pre-Deployment Checklist

### Legal Requirements
- [ ] Privacy Policy hosted at accessible URL
- [ ] Terms of Service available
- [ ] App icon designed (1024x1024 for iOS, 512x512 for Android)
- [ ] Screenshots captured for all required device sizes
- [ ] App description written

### Technical Requirements
- [ ] Unique package/bundle ID: `app.snapbeam.photo`
- [ ] Version number set in pubspec.yaml
- [ ] Build number incremented
- [ ] Backend API deployed and tested
- [ ] All permissions justified and documented

---

## 🤖 Google Play Store Deployment

### Step 1: Create Google Play Developer Account
1. Go to [Google Play Console](https://play.google.com/console)
2. Pay one-time $25 registration fee
3. Complete account setup

### Step 2: Create App in Console
1. Click "Create app"
2. Fill in app details:
   - App name: **SnapBeam**
   - Default language: **English**
   - Free or paid: **Free**
   - Declarations: Accept all

### Step 3: Build Release APK/AAB

```bash
# Navigate to Flutter project
cd flutter-app

# Get dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create

# Build release AAB (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Sign the App

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=snapbeam
storeFile=/path/to/snapbeam-keystore.jks
```

Generate signing key:
```bash
keytool -genkey -v -keystore snapbeam-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias snapbeam
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 5: Upload to Play Console

1. Go to **Release > Testing > Internal testing**
2. Click **Create new release**
3. Upload AAB file
4. Fill in release notes
5. Save and review
6. Roll out to internal testing

### Step 6: Complete Store Listing

**Main Store Listing:**
- App name: SnapBeam
- Short description: Send photos instantly to your loved one's home screen widget.
- Full description: (See APP_STORE_METADATA.md)

**Graphics:**
- App icon: 512x512 PNG
- Feature graphic: 1024x500 PNG
- Screenshots: At least 2 for phone

**Categorization:**
- Category: Photography
- Tags: photo, sharing, widget, family

**Content Rating:**
- Complete questionnaire
- Expected rating: Everyone

### Step 7: Submit for Review

1. Complete all sections with green checkmarks
2. Go to **Release > Production**
3. Create new release
4. Promote from internal testing
5. Roll out to 100%
6. Submit for review

**Review Time:** Typically 1-3 days

---

## 🍎 Apple App Store Deployment

### Step 1: Enroll in Apple Developer Program
1. Go to [Apple Developer](https://developer.apple.com)
2. Enroll ($99/year)
3. Complete enrollment (may take 24-48 hours)

### Step 2: Create App ID
1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers)
2. Click **+** to add new identifier
3. Select **App IDs**
4. Fill in:
   - Description: SnapBeam
   - Bundle ID: `app.snapbeam.photo` (Explicit)
   - Capabilities: 
     - Push Notifications (if needed)
     - App Groups (for widgets)
5. Register

### Step 3: Create App in App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **+** > **New App**
3. Fill in:
   - Platform: iOS
   - Name: SnapBeam
   - Primary language: English
   - Bundle ID: `app.snapbeam.photo`
   - SKU: snapbeam-ios-001
   - User access: Full access

### Step 4: Build Release IPA

```bash
# Navigate to Flutter project
cd flutter-app

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release

# Open Xcode workspace
open ios/Runner.xcworkspace
```

### Step 5: Configure in Xcode

1. Select **Runner** project
2. Set **Bundle Identifier**: `app.snapbeam.photo`
3. Set **Version**: 1.0.0
4. Set **Build**: 1
5. Select your **Team** (from Developer account)
6. Configure capabilities:
   - Enable **App Groups** (for widgets)
   - Add group: `group.app.snapbeam.photo`

### Step 6: Archive and Upload

In Xcode:
1. Select **Any iOS Device** as target
2. Menu: **Product > Archive**
3. Wait for archive to complete
4. Click **Distribute App**
5. Select **App Store Connect**
6. Select **Upload**
7. Keep default options
8. Upload

### Step 7: Complete Store Listing

**App Information:**
- Name: SnapBeam
- Subtitle: Instant photo sharing
- Category: Photo & Video
- Content Rating: 4+

**Screenshots:**
- Required: 6.7", 6.5", 5.5" iPhone
- Optional: 12.9", 11" iPad

**App Description:** (See APP_STORE_METADATA.md)

**What's New:**
```
🎉 Initial Release!

✨ Features:
- Instant photo sharing
- Home screen widgets
- No account required
- Multi-language support
```

**Privacy:**
- Privacy Policy URL: https://snapbeam.app/privacy

### Step 8: Submit for Review

1. Complete all sections
2. Click **Add for Review**
3. Submit to App Review

**Review Time:** Typically 24-48 hours

---

## 🔧 Troubleshooting

### Common Android Issues

**Issue:** Upload failed - APK not signed
**Solution:** Ensure signing configuration is correct in build.gradle

**Issue:** App rejected - Missing privacy policy
**Solution:** Add privacy policy URL in Store Listing

**Issue:** App rejected - Screenshots missing
**Solution:** Upload at least 2 screenshots for each form factor

### Common iOS Issues

**Issue:** Upload failed - Invalid IPA
**Solution:** Ensure correct provisioning profile and certificate

**Issue:** App rejected - Missing usage descriptions
**Solution:** Add NSCameraUsageDescription and NSPhotoLibraryUsageDescription to Info.plist

**Issue:** App rejected - Privacy manifest missing
**Solution:** Add PrivacyInfo.xcprivacy file (included)

---

## 📊 Post-Launch

### Monitor
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Monitor App Store/Play Console for reviews
- [ ] Track user feedback

### Update Process

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```

2. Build new release:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release  # Android
   flutter build ios --release        # iOS
   ```

3. Upload to stores
4. Submit for review
5. Roll out after approval

---

## 🔐 Security Best Practices

1. **Never commit signing keys** - Add to .gitignore
2. **Use environment variables** for sensitive data
3. **Enable 2FA** on developer accounts
4. **Regular security audits** of code
5. **Keep dependencies updated**

---

## 📝 Store URLs

After approval, your app will be available at:

- **Play Store**: `https://play.google.com/store/apps/details?id=app.snapbeam.photo`
- **App Store**: `https://apps.apple.com/app/snapbeam/id[YOUR_APP_ID]`
