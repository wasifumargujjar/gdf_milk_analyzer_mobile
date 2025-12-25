# Quick Start Guide - Milk Analyzer Identity Flow

## 🚀 Getting Started in 5 Minutes

### Step 1: Configure API URL (REQUIRED)

Open `lib/config/api_config.dart` and update the base URL:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

Replace `https://your-api-url.com` with your actual backend API URL.

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the App

```bash
flutter run
```

That's it! The app is now ready to use.

## 📱 Testing the Flows

### Test Login
1. Launch the app
2. Enter username/email and password
3. Tap "Login"

### Test Simple Registration
1. On login screen, tap "Register"
2. Fill in the form
3. Tap "Register"
4. Go back to login and sign in

### Test Registration with Email Confirmation
1. On login screen, tap "Register with Email Confirmation"
2. Fill in the form
3. Tap "Register"
4. Check email for confirmation link
5. Click the link (app will open)
6. Go back to login and sign in

### Test Forgot Password
1. On login screen, tap "Forgot Password?"
2. Enter email address
3. Tap "Send Reset Link"
4. Check email for reset link
5. Click the link (app will open)
6. Enter new password
7. Go back to login with new password

## 🔧 Deep Link Testing

### Android (using adb)
```bash
# Test email confirmation
adb shell am start -W -a android.intent.action.VIEW \
  -d "milkanalyzer://confirm-email?userId=1&token=abc123"

# Test password reset
adb shell am start -W -a android.intent.action.VIEW \
  -d "milkanalyzer://reset-password?userId=1&token=abc123"
```

### iOS Simulator
```bash
# Test email confirmation
xcrun simctl openurl booted "milkanalyzer://confirm-email?userId=1&token=abc123"

# Test password reset
xcrun simctl openurl booted "milkanalyzer://reset-password?userId=1&token=abc123"
```

## 🔐 Default Test Credentials

Use these if your backend has seed data:
- **Username**: admin / testuser
- **Password**: password123

(Check with your backend team for actual test credentials)

## 📋 Backend Email Link Format

Update your backend email templates to use these formats:

**Email Confirmation Link:**
```
milkanalyzer://confirm-email?userId={userId}&token={encodedToken}
```

**Password Reset Link:**
```
milkanalyzer://reset-password?userId={userId}&token={encodedToken}
```

## ❓ Troubleshooting

### "No internet connection" error
- Check that the API URL is correct in `api_config.dart`
- Verify your device/emulator has internet access
- Ensure the backend API is running

### Deep links not working
- For Android: Check `android/app/src/main/AndroidManifest.xml` has the intent filters
- For iOS: Check `ios/Runner/Info.plist` has the CFBundleURLTypes
- Reinstall the app after making changes

### Build runner fails
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Token expired" or authentication errors
- Logout and login again
- Clear app data and reinstall

## 📖 Full Documentation

For detailed information, see [IDENTITY_FLOW_README.md](IDENTITY_FLOW_README.md)

## 🎯 What's Included

✅ Login Screen  
✅ Registration (2 types)  
✅ Forgot Password  
✅ Password Reset  
✅ Email Confirmation  
✅ Home/Dashboard  
✅ Secure Token Storage  
✅ Deep Linking  
✅ State Management (Riverpod)  
✅ Navigation (GoRouter)  
✅ Auth Guards  

## 🔄 Next Steps

1. Customize the theme in `main.dart`
2. Add your app logo/branding
3. Implement business features
4. Add error tracking (Sentry, Firebase Crashlytics)
5. Setup analytics
6. Write tests

## 💡 Tips

- The app automatically checks auth status on startup
- Tokens are stored securely and persist across app restarts
- All API errors are handled and displayed to users
- Navigation guards prevent unauthorized access
- Logout blacklists the token on the server

Enjoy building! 🎉
