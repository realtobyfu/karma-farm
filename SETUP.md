# Karma Farm Setup Guide

## 🔐 Security Setup (Required)

### Firebase Configuration

1. **Copy the template file:**
   ```bash
   cp "Karma Farm/GoogleService-Info.plist.template" "Karma Farm/GoogleService-Info.plist"
   ```

2. **Get your Firebase credentials:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (or create a new one)
   - Go to Project Settings → General → Your Apps
   - Download the iOS configuration file or copy the values

3. **Update the configuration file:**
   Edit `Karma Farm/GoogleService-Info.plist` and replace the placeholder values:
   - `YOUR_FIREBASE_API_KEY_HERE` → Your Firebase API Key
   - `YOUR_GCM_SENDER_ID_HERE` → Your GCM Sender ID
   - `YOUR_FIREBASE_PROJECT_ID_HERE` → Your Firebase Project ID
   - `YOUR_GOOGLE_APP_ID_HERE` → Your Google App ID
   - `YOUR_GOOGLE_CLIENT_ID_HERE` → Your Google Client ID
   - `YOUR_REVERSED_CLIENT_ID_HERE` → Your Reversed Client ID

⚠️ **IMPORTANT**: Never commit the actual `GoogleService-Info.plist` file to git. It contains sensitive API keys.

## 🚀 Development Setup

1. **Prerequisites:**
   - Xcode 15.0 or later
   - iOS 17.6+ deployment target
   - macOS Ventura or later

2. **Clone and setup:**
   ```bash
   git clone <your-repo-url>
   cd karma-farm
   ```

3. **Open in Xcode:**
   ```bash
   open "Karma Farm.xcodeproj"
   ```

4. **Install dependencies:**
   Dependencies are managed via Swift Package Manager and should auto-resolve in Xcode.

## 🔧 API Configuration

The app currently uses a local development server at `http://127.0.0.1:3000`.

To modify the API endpoint:
1. Edit `Karma Farm/Services/APIService.swift`
2. Update the `APIConfig.baseURL` values for DEBUG and release builds

## 📱 Running the App

1. Select your target device/simulator in Xcode
2. Press ⌘+R to build and run
3. The app will launch with the configured Firebase authentication

## 🛡️ Security Best Practices

- **Never commit sensitive files** like `GoogleService-Info.plist`
- **Rotate API keys** if they've been exposed
- **Use environment-specific configurations** for different deployment stages
- **Review .gitignore** before committing any new files

## 🆘 Troubleshooting

### Firebase Authentication Issues
- Ensure your `GoogleService-Info.plist` has correct values
- Check that your bundle ID matches Firebase project settings
- Verify iOS keys are configured in Firebase Console

### Build Errors
- Clean build folder: Product → Clean Build Folder (⌘+Shift+K)
- Reset package cache: File → Packages → Reset Package Caches
- Check that all dependencies resolved correctly

## 📄 Project Structure

```
Karma Farm/
├── Core/
│   ├── Authentication/
│   ├── Feed/
│   ├── Chat/
│   ├── Profile/
│   └── Onboarding/
├── Models/
├── Services/
└── GoogleService-Info.plist (local only - not in git)
```

---

Need help? Check the existing issues or create a new one in the repository.