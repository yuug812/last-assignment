# Firebase Setup Guide

This guide will help you set up Firebase for the Recipe Share app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name (e.g., "recipe-share-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Click on "Email/Password"
5. Enable "Email/Password" authentication
6. Click "Save"

## Step 3: Create Firestore Database

1. In your Firebase project, go to "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database (choose the closest to your users)
5. Click "Done"

### Firestore Security Rules
Update your Firestore security rules to allow read/write access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read all recipes
    match /recipes/{recipeId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Allow users to read/write their own user data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 4: Enable Firebase Storage

1. In your Firebase project, go to "Storage" in the left sidebar
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select a location for your storage (same as Firestore)
5. Click "Done"

### Storage Security Rules
Update your Storage security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /recipes/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 5: Add Your App to Firebase

### For Android:
1. In your Firebase project, click the Android icon (</>) to add an Android app
2. Enter your Android package name: `com.example.assignment`
3. Enter app nickname: "Recipe Share"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place it in `android/app/google-services.json`

### For iOS:
1. In your Firebase project, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID: `com.example.assignment`
3. Enter app nickname: "Recipe Share"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place it in `ios/Runner/GoogleService-Info.plist`

## Step 6: Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with your actual Firebase project settings:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-storage-bucket',
);
```

You can find these values in:
- Firebase Console → Project Settings → General → Your apps

## Step 7: Test the Setup

1. Run the app: `flutter run`
2. Try to create an account
3. Try to add a recipe with an image
4. Verify that data appears in Firestore and images in Storage

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Make sure you've added the configuration files
   - Check that `firebase_options.dart` has correct values

2. **Authentication not working**
   - Verify Email/Password is enabled in Firebase Console
   - Check that the app is properly registered

3. **Image upload fails**
   - Check Storage security rules
   - Verify internet connectivity
   - Check Storage bucket permissions

4. **Database operations fail**
   - Check Firestore security rules
   - Verify the database is created and accessible

### Getting Firebase Configuration Values:

1. Go to Firebase Console
2. Click on your project
3. Go to Project Settings (gear icon)
4. Scroll down to "Your apps"
5. Click on your app
6. Copy the configuration values

## Security Notes

For production:
1. Update Firestore rules to be more restrictive
2. Update Storage rules to limit access
3. Enable additional authentication methods if needed
4. Set up proper user roles and permissions

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/) 