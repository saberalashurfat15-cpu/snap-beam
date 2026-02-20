@echo off
REM SnapBeam Flutter Build Script for Windows
REM Generates APK for testing before Play Store launch

echo ======================================
echo   SnapBeam APK Build Script
echo ======================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Flutter is not installed!
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install
    exit /b 1
)

echo Flutter found:
flutter --version | findstr /i "Flutter"
echo.

REM Navigate to Flutter project
cd /d "%~dp0..\flutter-app"

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build APK
echo.
echo Building debug APK...
flutter build apk --debug

if %ERRORLEVEL% equ 0 (
    echo.
    echo APK built successfully!
    echo.
    echo APK Location:
    echo %cd%\build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo To install on connected device:
    echo flutter install
    echo.
) else (
    echo.
    echo Build failed. Check the errors above.
    exit /b 1
)

echo ======================================
echo   Build Complete!
echo ======================================
