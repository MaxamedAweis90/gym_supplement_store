# Firestore Security Rules Setup

## Overview
This document explains how to set up Firestore security rules for the Gym Supplement Store app.

## Current Rules
The `firestore.rules` file contains basic security rules that:
- Allow public read access to products
- Allow authenticated users to write to products
- Allow users to manage their own profiles
- Allow admins to manage admin data

## Deploying Rules

### Option 1: Using Firebase CLI
1. Install Firebase CLI if you haven't already:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project (if not already done):
   ```bash
   firebase init firestore
   ```

4. Deploy the rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 2: Using Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Firestore Database
4. Click on the "Rules" tab
5. Copy the contents of `firestore.rules` and paste them
6. Click "Publish"

## Testing Rules
You can test your rules using the Firebase Console:
1. Go to Firestore Database > Rules
2. Click "Rules Playground"
3. Test different scenarios to ensure your rules work as expected

## Troubleshooting
If you're still getting permission errors:
1. Make sure you're authenticated in the app
2. Check that the user has the necessary permissions
3. Verify the rules are deployed correctly
4. Check the Firebase Console logs for more details

## Security Considerations
- These rules allow public read access to products, which is appropriate for an e-commerce app
- Write access is restricted to authenticated users
- Consider adding more granular permissions based on user roles (admin vs regular user)
- Regularly review and update rules as your app evolves 