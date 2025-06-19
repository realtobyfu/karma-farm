# Karma Farm Testing Guide

## Overview
This guide covers how to test phone authentication and app functionality in both mock and real environments.

## Quick Start Testing

### 1. Phone Authentication Issues - Troubleshooting

**The main issues with phone verification were:**

1. **Missing APNs Setup** ✅ FIXED
   - Added proper `AppDelegate` with APNs token handling
   - Required for SMS verification on physical devices

2. **Missing URL Schemes** ✅ FIXED
   - Added Firebase URL scheme to `Info.plist`
   - Required for Firebase authentication flow

3. **Incomplete Firebase Configuration** ✅ FIXED
   - Added proper imports and auth language setup
   - Improved async/await error handling

4. **Missing Mock Infrastructure** ✅ FIXED
   - Added comprehensive mock data for testing
   - Created `MockAuthManager` for UI development

### 2. Testing Environments

#### Mock Testing (Recommended for Development)
```swift
// Use these in SwiftUI previews:
ContentView()
    .environmentObject(AuthManager.mockAuthenticated as! AuthManager)

// Or for unauthenticated state:
PhoneAuthView()
    .environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
```

**Mock Authentication Features:**
- Uses verification code "123456" for success
- Any other code triggers error state
- Simulates network delays realistically
- No Firebase connection required

#### Real Firebase Testing
- Requires physical device for SMS
- Uses real phone numbers only
- Requires network connection
- Check Firebase Console for quotas

## Step-by-Step Testing

### Phase 1: UI Testing with Mocks

1. **Test Phone Auth UI:**
   ```swift
   #Preview("Phone Auth - Initial") {
       PhoneAuthView()
           .environmentObject(AuthManager.mockUnauthenticated as! AuthManager)
   }
   ```

2. **Test Authenticated State:**
   ```swift
   #Preview("Authenticated App") {
       ContentView()
           .environmentObject(AuthManager.mockAuthenticated as! AuthManager)
   }
   ```

3. **Test Error States:**
   - Use any code except "123456" in mock auth
   - See error messages and handling

### Phase 2: Real Phone Testing

1. **Prerequisites:**
   - Physical iOS device
   - Real phone number
   - Firebase project with phone auth enabled
   - Network connectivity

2. **Firebase Console Checks:**
   - Go to Authentication → Sign-in methods
   - Verify "Phone" is enabled
   - Check Authentication → Usage for SMS quotas
   - Monitor Authentication → Users for account creation

3. **Testing Process:**
   ```
   1. Enter real phone number with country code (+1234567890)
   2. Wait for SMS (may take 1-2 minutes)
   3. Enter 6-digit verification code
   4. Check Firebase Console for user creation
   ```

### Phase 3: Backend Integration

1. **Start Backend:**
   ```bash
   cd backend
   npm install
   npm run start:dev
   ```

2. **Test API Endpoints:**
   ```bash
   # Health check
   curl http://localhost:3000
   
   # Auth verification (requires Firebase ID token)
   curl -X POST http://localhost:3000/auth/verify \
     -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
     -H "Content-Type: application/json"
   ```

3. **Monitor API Logs:**
   - Check console for API request/response logs
   - Verify token validation
   - Check database user creation

## Common Issues & Solutions

### Phone Authentication Not Working

#### Issue: "Invalid phone number format"
**Solution:**
- Use international format: +1234567890
- Include country code
- Remove spaces and special characters

#### Issue: SMS not received
**Solutions:**
1. Check Firebase quotas in Console
2. Verify phone number format
3. Check device network connectivity
4. Try different phone number
5. Check spam folder

#### Issue: "reCAPTCHA verification failed"
**Solutions:**
1. Add domain to Firebase authorized domains
2. Enable Google Cloud billing for production
3. Wait a few minutes and retry

#### Issue: "Missing APNs token" warnings
**Status:** Normal for iOS Simulator
- APNs only works on physical devices
- Simulator will show reCAPTCHA instead
- App handles this automatically

### Backend Connection Issues

#### Issue: Network errors / API not reachable
**Solutions:**
1. Verify backend is running on localhost:3000
2. Check iOS Simulator network connectivity
3. Update `APIConfig.baseURL` if needed
4. Check firewall/proxy settings

#### Issue: Authentication failures
**Solutions:**
1. Verify Firebase credentials in backend .env
2. Check service account JSON is valid
3. Ensure Firebase project ID matches
4. Check backend logs for detailed errors

## Testing Checklist

### Pre-Testing Setup
- [ ] Backend running with correct environment variables
- [ ] Firebase project configured for phone auth
- [ ] iOS app has GoogleService-Info.plist
- [ ] URL schemes configured in Info.plist
- [ ] Physical device available for real testing

### Mock Testing
- [ ] Phone auth UI displays correctly
- [ ] Country picker works
- [ ] Phone number formatting works
- [ ] Verification code "123456" succeeds
- [ ] Other codes show error state
- [ ] Loading states display properly
- [ ] All views have working previews

### Real Phone Testing
- [ ] Phone number validation works
- [ ] SMS received within 2 minutes
- [ ] Verification code works
- [ ] User created in Firebase Console
- [ ] App transitions to authenticated state
- [ ] Backend receives and validates token

### Integration Testing
- [ ] API calls work with real tokens
- [ ] Mock data displays in feeds
- [ ] Navigation between tabs works
- [ ] Profile data loads correctly
- [ ] Sign out functionality works

## Debug Commands

### View Firebase Debug Info
```bash
# In Xcode console, look for:
# Firebase Auth debug messages
# Network request logs
# API response data
```

### Check Network Status
```swift
// Test network connectivity
let isConnected = await APIService.shared.checkNetworkStatus()
print("Network status: \(isConnected)")
```

### Reset Mock State
```swift
// Reset mock authentication for testing
TestAPIService.resetMockState()
```

## Production Considerations

### Before Production Release
1. Update `APIConfig.baseURL` to production URL
2. Disable debug logging (`TestingConfig.enableDebugLogging = false`)
3. Test thoroughly with multiple phone numbers
4. Verify Firebase quotas and billing
5. Test on multiple devices and iOS versions
6. Add proper error analytics and reporting

### Security Checklist
- [ ] Firebase rules properly configured
- [ ] Backend validates all tokens
- [ ] Phone numbers are properly validated
- [ ] User data is sanitized
- [ ] Rate limiting implemented
- [ ] Production Firebase credentials secured

## Support

For additional testing issues:
1. Check Firebase Console logs
2. Monitor backend console output
3. Use Xcode debugger for client issues
4. Test with MockAPIService.shared for isolated testing
5. Review this guide's troubleshooting sections 