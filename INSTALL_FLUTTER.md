# Flutter Installation Guide for Windows

## Step-by-Step Installation

### Step 1: Download Flutter

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Click the **"Download Flutter SDK"** button
3. Or download directly: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
4. Save the file to your Downloads folder

### Step 2: Extract Flutter

1. Go to your Downloads folder
2. Right-click on `flutter_windows_3.24.5-stable.zip`
3. Select "Extract All..."
4. Extract to: `C:\`
   - This will create `C:\flutter`
   - **Important:** Extract directly to C:\ not C:\Users\...

### Step 3: Add Flutter to PATH

1. Press `Windows Key` and search for **"Environment Variables"**
2. Click **"Edit the system environment variables"**
3. Click the **"Environment Variables..."** button
4. Under **"User variables"**, find and select **"Path"**
5. Click **"Edit..."**
6. Click **"New"**
7. Add: `C:\flutter\bin`
8. Click **"OK"** on all windows

### Step 4: Verify Installation

1. **Close and reopen** your terminal/PowerShell
2. Run this command:

```bash
flutter doctor
```

You should see Flutter checking your system!

### Step 5: Accept Android Licenses (if using Android)

If you plan to build for Android:

```bash
flutter doctor --android-licenses
```

Type `y` to accept all licenses.

## What You'll See

After running `flutter doctor`, you'll see a checklist like:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.24.5)
[✗] Android toolchain - develop for Android devices
[✗] Chrome - develop for the web
[✗] Visual Studio - develop Windows apps
[✗] Android Studio (not installed)
[✓] VS Code (version 1.XX)
```

**Don't worry if some items have ✗** - you only need:
- ✓ Flutter
- ✓ Android toolchain (if building for Android)
- ✓ Xcode (if building for iOS, Mac only)

## Installing Android Studio (Optional but Recommended)

If you want to test on Android:

1. Download: https://developer.android.com/studio
2. Install Android Studio
3. During setup, make sure to install:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator
4. After installation, run `flutter doctor` again

## Quick Test

After installation, try these commands:

```bash
# Check Flutter is working
flutter --version

# See available devices
flutter devices

# Create a test project
flutter create test_app
cd test_app
flutter run
```

## Troubleshooting

### "flutter is not recognized"
- Make sure you added `C:\flutter\bin` to PATH correctly
- **Restart your terminal** after changing PATH
- Try opening a new Command Prompt or PowerShell window

### "Android license status unknown"
- Run: `flutter doctor --android-licenses`
- Accept all licenses by typing `y`

### "No devices found"
- Install Android Studio and create an emulator
- Or connect a physical phone with USB debugging enabled

## Need Help?

Once you've completed these steps, come back and let me know if you see any errors from `flutter doctor`!

---

**Total install time: ~15-30 minutes** (depending on download speed)
