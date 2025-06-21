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

## 4. Create Storage Bucket

1. In your Supabase dashboard, go to **Storage**
2. Click "Create a new bucket"
3. Enter the following details:
   - **Name**: `product-images`
   - **Public bucket**: ✅ Check this option
   - **File size limit**: `5MB` (or your preferred limit)
   - **Allowed MIME types**: `image/*`
4. Click "Create bucket"

## 5. Set Up Storage Policies

1. In the Storage section, click on your `product-images` bucket
2. Go to **Policies** tab
3. Add the following policies:

### Policy 1: Allow public read access
```sql
-- Policy name: "Public read access"
-- Operation: SELECT
-- Target roles: public
-- Policy definition:
true
```

### Policy 2: Allow authenticated users to upload
```sql
-- Policy name: "Authenticated users can upload"
-- Operation: INSERT
-- Target roles: authenticated
-- Policy definition:
auth.role() = 'authenticated'
```

### Policy 3: Allow users to update their own uploads
```sql
-- Policy name: "Users can update own uploads"
-- Operation: UPDATE
-- Target roles: authenticated
-- Policy definition:
auth.role() = 'authenticated'
```

### Policy 4: Allow users to delete their own uploads
```sql
-- Policy name: "Users can delete own uploads"
-- Operation: DELETE
-- Target roles: authenticated
-- Policy definition:
auth.role() = 'authenticated'
```

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

- The anon key is safe to use in client-side code
- Never expose your service role key in the client
- Use Row Level Security (RLS) policies for sensitive data
- Regularly review and update your storage policies
- Monitor your storage usage and costs

## 13. Cost Optimization

- Set appropriate file size limits
- Use image transformations to serve optimized images
- Implement image compression before upload
- Consider using CDN for better performance
- Monitor your storage and bandwidth usage 