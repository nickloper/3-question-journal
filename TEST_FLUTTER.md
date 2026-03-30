# Flutter Installation Troubleshooting

## Test These Commands (Copy & Paste)

Open a **NEW** Command Prompt or PowerShell and try:

### Test 1: Check if Flutter is found
```cmd
flutter --version
```

**Expected result:** Should show Flutter version info
**If it fails:** PATH is not set correctly

---

### Test 2: Check your PATH variable
```cmd
echo %PATH%
```

**What to look for:** You should see `C:\flutter\bin` somewhere in the output

---

### Test 3: Direct path test
```cmd
C:\flutter\bin\flutter.bat --version
```

**If this works:** Flutter is installed but PATH isn't set
**If this fails:** Flutter isn't extracted to C:\flutter

---

## Common Issues & Fixes

### Issue 1: "flutter is not recognized as an internal or external command"

**Fix:**
1. Did you close and reopen your terminal? (MUST do this!)
2. Check PATH was added correctly:
   - Windows Key → "Environment Variables"
   - Under "User variables" → Select "Path" → Edit
   - Look for `C:\flutter\bin` in the list
   - If not there, click "New" and add it
   - Click OK on ALL windows
3. Close ALL terminals and open fresh

---

### Issue 2: PATH looks wrong

The PATH entry should be EXACTLY:
```
C:\flutter\bin
```

NOT:
- ❌ `C:\flutter`
- ❌ `C:\flutter\bin\`
- ❌ `C:/flutter/bin`

---

### Issue 3: Flutter extracted to wrong location

Run this to check:
```cmd
dir C:\flutter
```

**Should show folders like:**
- bin
- packages
- README.md
- etc.

**If you get "cannot find the path":**
- Flutter isn't in C:\flutter
- Go back and extract the ZIP directly to C:\

---

## Step-by-Step PATH Fix

If PATH isn't working:

1. Press `Windows Key`
2. Type: **"environment"**
3. Click: **"Edit the system environment variables"**
4. Click: **"Environment Variables..."** button (bottom)
5. Under "User variables" section (top half):
   - Find and click on **"Path"**
   - Click **"Edit..."**
6. Check if `C:\flutter\bin` is in the list
7. If NOT there:
   - Click **"New"**
   - Type: `C:\flutter\bin`
   - Click **"OK"**
8. Click **"OK"** on Environment Variables window
9. Click **"OK"** on System Properties window
10. **CLOSE ALL terminals**
11. Open a fresh Command Prompt
12. Try: `flutter --version`

---

## Still Not Working?

**Alternative: Use full path for now**

Instead of `flutter`, use the full path:
```cmd
C:\flutter\bin\flutter --version
C:\flutter\bin\flutter doctor
C:\flutter\bin\flutter pub get
```

This will work even if PATH isn't set.

---

## Tell me what you see

Run these and tell me the results:

1. `flutter --version` → What error/output?
2. `echo %PATH%` → Do you see flutter\bin?
3. `dir C:\flutter` → Does it list files?

I'll help you fix it based on what you see!
