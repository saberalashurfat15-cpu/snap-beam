#!/bin/bash

# SnapBeam Flutter Build Script
# Generates APK for testing before Play Store launch

echo "======================================"
echo "  SnapBeam APK Build Script"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"
echo ""

# Navigate to Flutter project
cd "$(dirname "$0")/../flutter-app" || exit 1

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check for required files
echo ""
echo "📋 Checking required assets..."

if [ ! -f "assets/images/app_icon.png" ]; then
    echo "⚠️  Warning: assets/images/app_icon.png not found"
    echo "   Creating placeholder..."
    mkdir -p assets/images
    echo "Place your 1024x1024 app icon here" > assets/images/README.md
fi

if [ ! -d "assets/fonts" ]; then
    echo "⚠️  Warning: assets/fonts/ directory not found"
    echo "   Creating placeholder..."
    mkdir -p assets/fonts
    echo "Place Poppins font files here" > assets/fonts/README.md
fi

# Build APK
echo ""
echo "🔨 Building debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ APK built successfully!"
    echo ""
    echo "📱 APK Location:"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-debug.apk"
    echo ""
    echo "📦 To install on connected device:"
    echo "   flutter install"
    echo ""
    echo "📦 To build release APK (for distribution):"
    echo "   flutter build apk --release"
    echo ""
else
    echo ""
    echo "❌ Build failed. Check the errors above."
    exit 1
fi

# Build release APK option
if [ "$1" == "--release" ]; then
    echo ""
    echo "🔨 Building release APK..."
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Release APK built successfully!"
        echo "📱 Location: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    fi
fi

echo ""
echo "======================================"
echo "  Build Complete!"
echo "======================================"
