# Milk Analyzer Flutter Application - Identity Flow Implementation

This is a comprehensive identity/authentication flow implementation for the Milk Analyzer Flutter application, featuring login, registration, password management, and email confirmation.

## Features Implemented

### 1. **Authentication (AuthController endpoints)**
- ✅ Login with username/email and password
- ✅ JWT token management with secure storage
- ✅ Logout with token blacklisting
- ✅ Simple registration (auto-confirms email)

### 2. **Account Management (AccountController endpoints)**
- ✅ Registration with email confirmation flow
- ✅ Email confirmation via deep links
- ✅ Forgot password functionality
- ✅ Password reset via deep links

### 3. **Technical Implementation**
- ✅ **State Management**: Riverpod 2.x (latest pattern)
- ✅ **Navigation**: GoRouter with authentication guards
- ✅ **Secure Storage**: flutter_secure_storage for tokens
- ✅ **API Service**: HTTP client with error handling
- ✅ **Deep Linking**: Support for email/password reset links
- ✅ **JSON Serialization**: json_serializable for models

## Project Structure

```
lib/
├── config/
│   └── api_config.dart              # API endpoints and configuration
├── models/
│   ├── auth_user.dart               # Authenticated user model
│   ├── forgot_password_model.dart   # Forgot password request
│   ├── login_request.dart           # Login request model
│   ├── login_response.dart          # Login response model
│   ├── register_model.dart          # Registration model
│   ├── reset_password_model.dart    # Reset password model
│   └── user_model.dart              # User data model
├── providers/
│   ├── auth_provider.dart           # Authentication state management
│   └── service_providers.dart       # Service dependencies
├── router/
│   └── app_router.dart              # GoRouter configuration
├── screens/
│   ├── confirm_email_screen.dart    # Email confirmation screen
│   ├── forgot_password_screen.dart  # Forgot password screen
│   ├── home_screen.dart             # Home/dashboard screen
│   ├── login_screen.dart            # Login screen
│   ├── register_simple_screen.dart  # Simple registration
│   ├── register_with_confirmation_screen.dart  # Registration with email
│   └── reset_password_screen.dart   # Password reset screen
├── services/
│   ├── api_service.dart             # HTTP client wrapper
│   ├── auth_api_service.dart        # Authentication API calls
│   ├── deep_link_service.dart       # Deep link handling
│   └── token_storage_service.dart   # Secure token storage
└── main.dart                         # Application entry point
```

## Setup Instructions

### 1. Configure API URL

Update the base URL in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-url.com';  // Update this!
  // ...
}
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

Run the build runner to generate JSON serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configure Deep Links

#### Android (`android/app/src/main/AndroidManifest.xml`)

Add inside the `<activity>` tag:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="milkanalyzer"
        android:host="confirm-email" />
    <data
        android:scheme="milkanalyzer"
        android:host="reset-password" />
</intent-filter>
```

#### iOS (`ios/Runner/Info.plist`)

Add inside the `<dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.milkanalyzer</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>milkanalyzer</string>
        </array>
    </dict>
</array>
```

### 5. Update Backend Email Links

In your backend email templates, use these URL formats:

**Email Confirmation:**
```
milkanalyzer://confirm-email?userId={userId}&token={encodedToken}
```

**Password Reset:**
```
milkanalyzer://reset-password?userId={userId}&token={encodedToken}
```

## User Flows

### Flow 1: Simple Registration → Login
1. User taps "Register" on login screen
2. Fills registration form (username, email, full name, password)
3. Account created and email auto-confirmed
4. User redirected to login
5. Login with credentials

### Flow 2: Registration with Email Confirmation
1. User taps "Register with Email Confirmation"
2. Fills registration form (email, full name, password)
3. Receives confirmation email
4. Clicks confirmation link in email
5. App opens to confirmation screen
6. User redirected to login
7. Login with credentials

### Flow 3: Password Reset
1. User taps "Forgot Password?" on login
2. Enters email address
3. Receives password reset email
4. Clicks reset link in email
5. App opens to reset password screen
6. Enters new password
7. User redirected to login
8. Login with new password

### Flow 4: Standard Login
1. User enters username/email and password
2. System validates credentials
3. JWT token stored securely
4. User redirected to home screen

### Flow 5: Logout
1. User taps logout button
2. Confirms logout
3. Token blacklisted on server
4. Local storage cleared
5. User redirected to login

## API Endpoints Used

### AuthController
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/register` - Simple registration

### AccountController
- `POST /api/account/register` - Registration with email confirmation
- `GET /api/account/confirm-email` - Confirm email address
- `POST /api/account/forgot-password` - Request password reset
- `POST /api/account/reset-password` - Reset password

## State Management with Riverpod

The app uses Riverpod for state management with the following providers:

- **authStateProvider**: Manages authentication state
- **tokenStorageProvider**: Provides token storage service
- **apiServiceProvider**: Provides HTTP client
- **authApiServiceProvider**: Provides authentication API service
- **routerProvider**: Provides GoRouter with auth guards

## Security Features

1. **JWT Token Storage**: Tokens stored securely using flutter_secure_storage
2. **Token Blacklisting**: Logout blacklists tokens on the server
3. **Auth Guards**: Protected routes redirect unauthenticated users
4. **Password Validation**: Minimum length requirements
5. **Locked Account Handling**: Displays message for locked accounts

## Running the App

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in debug mode with hot reload
flutter run --debug
```

## Testing Deep Links

### Android
```bash
adb shell am start -W -a android.intent.action.VIEW \
  -d "milkanalyzer://confirm-email?userId=1&token=abc123"
```

### iOS (Simulator)
```bash
xcrun simctl openurl booted "milkanalyzer://confirm-email?userId=1&token=abc123"
```

## Common Issues and Solutions

### 1. Build Runner Issues
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Deep Links Not Working
- Ensure AndroidManifest.xml and Info.plist are properly configured
- Check that the URL scheme matches your configuration
- Verify the app is installed on the device

### 3. API Connection Issues
- Update the base URL in `api_config.dart`
- Check network connectivity
- Verify API endpoints are accessible

### 4. Token Storage Issues
- Clear app data and try again
- Check permissions for secure storage

## Next Steps

1. **Update API URL**: Configure your actual API base URL
2. **Customize Theme**: Modify theme in main.dart
3. **Add Features**: Implement milk analysis features
4. **Testing**: Write unit and integration tests
5. **CI/CD**: Setup continuous integration

## Dependencies

Key packages used:
- `flutter_riverpod`: ^2.6.1 - State management
- `go_router`: ^14.6.2 - Navigation
- `http`: ^1.2.2 - HTTP client
- `flutter_secure_storage`: ^9.2.2 - Secure storage
- `uni_links`: ^0.5.1 - Deep linking
- `json_annotation`: ^4.9.0 - JSON serialization

## License

[Add your license here]

## Support

For issues or questions, contact [your contact info]
