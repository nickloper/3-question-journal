# Quick Start Guide

Get your 3 Question Journal app running in minutes!

## Prerequisites Check

Make sure you have Flutter installed:

```bash
flutter doctor
```

If not installed, download from: https://flutter.dev/docs/get-started/install

## Installation Steps

### 1. Install Dependencies

```bash
cd "C:\Users\nlope\Documents\Claude Projects\3 Question Journal"
flutter pub get
```

### 2. Run the App

#### Option A: Using an Emulator

```bash
# Start an Android emulator or iOS simulator first, then:
flutter run
```

#### Option B: On Your Phone

1. **Android:**
   - Enable Developer Options on your phone
   - Enable USB Debugging
   - Connect via USB
   - Run: `flutter run`

2. **iPhone:**
   - Connect via USB
   - Trust the computer
   - Run: `flutter run`

## Testing the App

Once running, you can:

1. **Write Your First Entry**
   - Answer the 3 questions
   - Tap "Save Entry"

2. **View History**
   - Tap the history icon (top right)
   - See your streak counter

3. **Set Up Reminders**
   - Tap the settings icon
   - Enable "Daily Reminders"
   - Choose your preferred time

4. **Test Editing**
   - Edit today's entry (allowed)
   - Try to edit yesterday's entry (locked)

## Building the App

### For Android

```bash
# Build APK you can install on any Android phone
flutter build apk --release

# Find it at: build/app/outputs/flutter-apk/app-release.apk
```

### For iOS (Mac only)

```bash
# Build for iOS
flutter build ios --release

# Then open Xcode to finish
open ios/Runner.xcworkspace
```

## Common Issues

### "Flutter command not found"
- Flutter is not in your system PATH
- Restart your terminal/IDE
- Reinstall Flutter and add to PATH

### "No devices found"
- Make sure an emulator is running OR
- Phone is connected via USB with debugging enabled

### Build fails
```bash
flutter clean
flutter pub get
flutter run
```

### Notifications not working
- Grant notification permissions when prompted
- Check phone's notification settings
- Disable battery optimization for the app

## Next Steps

1. **Customize the app** - See README.md for customization options
2. **Share with friends** - Send them the APK file
3. **Build the habit** - Journal every evening!

## Need Help?

- Check the main README.md for detailed information
- Visit https://flutter.dev/docs for Flutter help
- Search Stack Overflow for specific errors

---

Happy journaling! 📝✨
