# Mobile Deployment Guide - Beyond Horizon Calculator

This document outlines the steps needed to deploy the Beyond Horizon Calculator as a mobile app on the Google Play Store.

## Current App Status

- Web version: ✅ Deployed on GitHub Pages
- Responsive Design: ✅ Already mobile-friendly
- Mobile Platform Support: ❌ Needs to be added

## Play Store Deployment Checklist

### 1. Technical Setup

- [ ] Install Android SDK (via Android Studio)
- [ ] Add Android platform support:
  ```bash
  flutter create . --platforms=android
  ```
- [ ] Configure app metadata in `android/app/build.gradle`:
  - Package name: `com.zartyblartfast.beyondhorizoncalc`
  - Version info
  - Minimum SDK version

### 2. App Store Listing Requirements

#### Required Graphics
- [ ] App Icon (512 x 512 px)
- [ ] Feature Graphic (1024 x 500 px)
- [ ] Screenshots (2-8 different screens)
  - Calculator main view
  - Preset selection
  - Mountain diagram
  - Results view

#### Text Content
- [ ] Short Description (80 chars max)
- [ ] Full Description (4000 chars max)
- [ ] Release Notes
- [ ] Privacy Policy
  - Simple policy stating no user data collection
  - Can be hosted on GitHub Pages

### 3. Google Play Developer Account

- [ ] Create Google Play Developer account
- [ ] Pay one-time $25 registration fee
- [ ] Set up merchant account (if planning paid features)

### 4. Build and Release Process

1. Create release keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

2. Configure signing in `android/key.properties`

3. Build release APK:
   ```bash
   flutter build appbundle
   ```

4. Test release version thoroughly

5. Upload to Play Console:
   - Submit app bundle
   - Fill in store listing
   - Set up release track (internal/alpha/beta/production)

## Benefits of Play Store Distribution

1. **Easy Installation**: Users can install directly from Play Store
2. **Automatic Updates**: Users get notified of new versions
3. **Credibility**: Official distribution channel
4. **Analytics**: Basic usage statistics
5. **Wide Reach**: Available to all Android users

## Future Considerations

- iOS deployment via App Store
- Mobile-specific features:
  - GPS integration for location input
  - Offline mode
  - Share functionality
  - Camera integration

## Resources

- [Flutter Android deployment docs](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Play Store listing guidelines](https://developer.android.com/distribute/best-practices/launch/store-listing)
