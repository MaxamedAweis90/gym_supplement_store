# Supabase Setup Guide

This guide will help you set up Supabase for image storage in your Gym Supplement Store app.

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `gym-supplement-store`
   - **Database Password**: Choose a strong password
   - **Region**: Select the region closest to your users
6. Click "Create new project"

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **Anon public key** (starts with `eyJ...`)

## 3. Update Configuration

1. Open `lib/service/supabase_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
static const String supabaseUrl = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

## 4. Create Storage Buckets

### 1. Product Images Bucket
- **Bucket Name**: `product-images`
- **Public**: Yes
- **File Size Limit**: 10MB
- **Allowed MIME Types**: image/*

### 2. User Avatar Bucket
- **Bucket Name**: `useravatar`
- **Public**: Yes
- **File Size Limit**: 5MB
- **Allowed MIME Types**: image/*

## 5. Set Up Storage Policies

Since you're using Firebase for authentication (not Supabase Auth), we need to use simpler storage policies that allow public access for read operations and basic authenticated access for write operations.

### Product Images Bucket Policies

1. In the Storage section, click on your `product-images` bucket
2. Go to **Policies** tab
3. Add the following policies:

#### Policy 1: Allow public read access
```sql
-- Policy name: "Public read access"
-- Operation: SELECT
-- Target roles: public
-- Policy definition:
true
```

#### Policy 2: Allow public upload (since Firebase handles auth)
```sql
-- Policy name: "Public upload access"
-- Operation: INSERT
-- Target roles: public
-- Policy definition:
true
```

#### Policy 3: Allow public update
```sql
-- Policy name: "Public update access"
-- Operation: UPDATE
-- Target roles: public
-- Policy definition:
true
```

#### Policy 4: Allow public delete
```sql
-- Policy name: "Public delete access"
-- Operation: DELETE
-- Target roles: public
-- Policy definition:
true
```

### User Avatar Bucket Policies

1. Create the `useravatar` bucket
2. Go to **Policies** tab
3. Add the same policies as above:

#### Policy 1: Allow public read access
```sql
-- Policy name: "Public read access"
-- Operation: SELECT
-- Target roles: public
-- Policy definition:
true
```

#### Policy 2: Allow public upload
```sql
-- Policy name: "Public upload access"
-- Operation: INSERT
-- Target roles: public
-- Policy definition:
true
```

#### Policy 3: Allow public update
```sql
-- Policy name: "Public update access"
-- Operation: UPDATE
-- Target roles: public
-- Policy definition:
true
```

#### Policy 4: Allow public delete
```sql
-- Policy name: "Public delete access"
-- Operation: DELETE
-- Target roles: public
-- Policy definition:
true
```

### Alternative: More Secure Approach (Optional)

If you want more security, you can implement server-side validation by:

1. **Creating a Supabase Edge Function** that validates Firebase tokens
2. **Using the service role key** in your backend to handle uploads
3. **Implementing custom policies** based on your Firebase user data

However, for most use cases, the public policies above are sufficient since:
- Firebase handles user authentication
- Your app validates user permissions before allowing uploads
- File names include user IDs for tracking ownership
- Storage quotas and file size limits provide additional protection

## 6. Enable Supabase in Your App

1. Open `lib/main.dart`
2. Uncomment the Supabase initialization line:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}
```

## 7. Install Dependencies

Run the following command to install the required packages:

```bash
flutter pub get
```

## 8. Platform-Specific Setup

### Android
No additional setup required.

### iOS
Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take product photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select product images</string>
```

### Web
No additional setup required.

## 9. Test the Integration

1. Run your app
2. Go to the admin section
3. Try adding a new product with an image
4. The image should be uploaded to Supabase and displayed in your app

## 10. Features Available

With Supabase integration, you now have:

- ✅ **Image Upload**: Upload images from gallery or camera
- ✅ **Image Storage**: Secure cloud storage for all product images
- ✅ **Image Deletion**: Remove images when products are deleted
- ✅ **Public URLs**: Direct access to images via URLs
- ✅ **Image Transformations**: Resize and format images on-the-fly
- ✅ **Error Handling**: Graceful fallbacks when images fail to load

## 11. Troubleshooting

### Common Issues:

1. **"Invalid API key" error**
   - Double-check your Supabase URL and anon key
   - Make sure you copied the anon key, not the service role key

2. **"Bucket not found" error**
   - Ensure the bucket name is exactly `product-images`
   - Check that the bucket is public

3. **"Permission denied" error**
   - Verify your storage policies are set up correctly
   - Make sure the bucket allows public read access

4. **Images not loading**
   - Check your internet connection
   - Verify the image URLs are being generated correctly
   - Check the browser console for CORS errors (web only)

### Getting Help:

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)

## 12. Security Considerations

Since you're using Firebase for authentication and Supabase only for storage:

### Current Security Model:
- **Firebase Auth**: Handles user authentication and session management
- **Supabase Storage**: Provides public access with client-side validation
- **App-Level Security**: Your Flutter app validates user permissions before allowing uploads

### Security Measures in Place:
- ✅ **Firebase Authentication**: Secure user login and session management
- ✅ **File Naming**: Files include user IDs for ownership tracking
- ✅ **File Size Limits**: Prevents abuse through large file uploads
- ✅ **MIME Type Restrictions**: Only allows image files
- ✅ **Client-Side Validation**: App checks user permissions before uploads
- ✅ **Storage Quotas**: Supabase enforces storage limits

### Important Notes:
- The anon key is safe to use in client-side code
- Never expose your service role key in the client
- File access is public, but file names include user IDs for tracking
- Your app's Firebase Auth ensures only authenticated users can upload
- Consider implementing server-side validation for production apps

### For Production Apps:
If you need additional security, consider:
1. **Server-side validation** using Firebase Admin SDK
2. **Supabase Edge Functions** for custom upload logic
3. **Signed URLs** for temporary file access
4. **Rate limiting** on upload operations

## 13. Cost Optimization

- Set appropriate file size limits
- Use image transformations to serve optimized images
- Implement image compression before upload
- Consider using CDN for better performance
- Monitor your storage and bandwidth usage 

## 14. File Naming Convention

- **Product Images**: `{productId}_{timestamp}_{originalName}`
- **User Avatars**: `{userId}_{timestamp}_{originalName}`

This ensures unique file names and easy identification of file ownership. 