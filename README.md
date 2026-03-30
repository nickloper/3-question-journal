# 3 Question Journal

A simple, beautiful daily journaling app built with Flutter. Reflect on your day with three focused questions every evening.

## Features

- **Three Daily Prompts**
  - What did I get done today?
  - What am I grateful for?
  - How will I win tomorrow?

- **Streak Tracking** - Build a journaling habit with visual streak tracking
- **Entry History** - Browse and review all your past entries
- **Daily Reminders** - Customizable notification times to remind you to journal
- **Edit Protection** - Edit today's entry anytime, but past entries are locked to preserve authenticity
- **Local Storage** - All data stays on your device, completely private
- **Calming Theme** - Blue/purple color palette designed for evening reflection

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK and emulator

3. **Xcode** (for iOS development, Mac only)
   - Download from Mac App Store
   - Install iOS Simulator

## Getting Started

### 1. Install Dependencies

Navigate to the project directory and run:

```bash
flutter pub get
```

### 2. Platform-Specific Setup

#### Android Setup

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following permissions inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

3. Add inside the `<application>` tag:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

#### iOS Setup

1. Open `ios/Runner/Info.plist`
2. Add the following before the closing `</dict>` tag:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3. Run the App

#### On an Emulator/Simulator

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run
```

#### On a Physical Device

1. Enable Developer Mode on your device
2. Connect via USB
3. Run: `flutter run`

## Building for Release

### Android APK

```bash
# Build APK
flutter build apk --release

# Find the APK at: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
# Build App Bundle
flutter build appbundle --release

# Find the bundle at: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Mac only)

```bash
# Build for iOS
flutter build ios --release

# Open Xcode to archive and submit
open ios/Runner.xcworkspace
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── journal_entry.dart            # Data model for journal entries
├── screens/
│   ├── home_screen.dart              # Daily journal prompt screen
│   ├── history_screen.dart           # View all past entries
│   ├── entry_detail_screen.dart      # View/edit individual entry
│   └── settings_screen.dart          # Notification settings
└── services/
    ├── database_service.dart         # SQLite database operations
    └── notification_service.dart     # Local notification handling
```

## How It Works

### Data Storage
- Uses SQLite for local database storage
- All entries are stored with timestamps
- Entries are automatically organized by date

### Notifications
- Uses `flutter_local_notifications` package
- Schedules daily reminders at user-specified time
- Repeats every 24 hours
- Can be enabled/disabled in settings

### Streak Tracking
- Automatically calculates consecutive days with entries
- Checks backward from today
- Resets if a day is missed

### Edit Restrictions
- Today's entry can be edited anytime
- Past entries are locked (read-only)
- Prevents accidental changes to historical reflections

## Customization

### Changing Colors

Edit the theme in `lib/main.dart`:

```dart
primaryColor: const Color(0xFF6B5B95), // Change this
secondary: const Color(0xFF7B8CDE),     // And this
```

### Changing Questions

Edit the questions in `lib/screens/home_screen.dart`:

```dart
_buildQuestionCard(
  number: '1',
  question: 'Your custom question?',
  controller: _accomplishedController,
  hint: 'Your custom hint...',
),
```

## Troubleshooting

### Notifications Not Working

**Android:**
- Check that notification permissions are granted
- Ensure "Do Not Disturb" is not blocking notifications
- Battery optimization might prevent scheduled notifications

**iOS:**
- Check notification permissions in Settings
- Ensure app has permission to send notifications

### Database Errors

- Clear app data and reinstall
- Check that SQLite dependencies are properly installed

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Next Steps

### Potential Enhancements
- Cloud backup/sync
- Export to PDF or text
- Data visualization (charts, graphs)
- Custom prompts
- Dark mode
- Themes and customization
- Password protection
- Search functionality

## License

This project is provided as-is for personal use and modification.

## Support

For issues or questions about Flutter development:
- Flutter Documentation: https://flutter.dev/docs
- Flutter Community: https://flutter.dev/community

---

**Built with Flutter** 💙
