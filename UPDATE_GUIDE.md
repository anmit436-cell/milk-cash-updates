# 🚀 Milk Cash - Enterprise Auto Update Guide

This document is your master guide for publishing updates to the Milk Cash app. The architecture has been built so that **you never have to modify the Flutter source code** to push an update to your users.

Follow these simple steps whenever you have a new version to release.

---

## 🛠️ Step 1: Prepare the New Release

When you have finished coding new features or bug fixes, you must increase the version number of the app.

1. Open `pubspec.yaml` in the root of your project.
2. Find the line starting with `version:`.
3. It will look like this: `version: 1.0.0+1`
4. Update it:
   - **Version Name** (before the `+`): Change `1.0.0` to `1.1.0` (for new features) or `1.0.1` (for bug fixes).
   - **Version Code** (after the `+`): **ALWAYS** increase this by 1. E.g., `+1` becomes `+2`.
   - Result: `version: 1.1.0+2`

## 📦 Step 2: Build the Release APK

You need to generate the final, signed APK that users will install.

1. Open your terminal in the root of the project.
2. Run the following command:
   ```bash
   flutter build apk --release
   ```
3. Once the build finishes, your new APK will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

## 🔒 Step 3: Generate the SHA-256 Hash

The update system uses a cryptographic hash to ensure the downloaded APK hasn't been corrupted or tampered with.

**On Windows (PowerShell):**
```powershell
Get-FileHash build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256
```

**On Mac/Linux:**
```bash
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
```

Copy the resulting long hash string (e.g., `8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92`).

## ☁️ Step 4: Upload the APK

You can host your APK anywhere that provides a direct download link (Firebase Hosting, AWS S3, GitHub Releases). 

If using **GitHub Releases**:
1. Go to your GitHub repository -> Releases -> Draft a new release.
2. Tag it `v1.1.0`.
3. Drag and drop your `app-release.apk` into the release assets.
4. Publish the release.
5. Right-click the `.apk` file in the release and copy the direct download link.

## 📝 Step 5: Update the JSON Metadata

The app checks a specific JSON file to know if an update exists. You need to update this file.
By default, the app is looking for the URL defined in `lib/update/repositories/update_repository.dart`. 

Create or edit your `update.json` file hosted on your server:

```json
{
  "latestVersion": "1.1.0",
  "versionCode": 2,
  "minimumVersion": "1.0.0",
  "apkUrl": "https://github.com/mishramilkcash/releases/download/v1.1.0/app-release.apk",
  "fileSize": "40 MB",
  "sha256": "PASTE_YOUR_SHA256_HASH_HERE",
  "packageName": "com.mishramilk.mishra_milk_cash",
  "status": "Active",
  "forceUpdate": false,
  "rolloutPercentage": 100,
  "releaseChannel": "Stable",
  "categorizedChangelog": {
    "🚀 Features": [
      "Added brand new dashboard",
      "New reporting system"
    ],
    "🐞 Bug Fixes": [
      "Fixed alignment issues on small screens"
    ]
  },
  "minAndroidVersion": 21,
  "maxAndroidVersion": 99,
  "supportedArchitectures": [],
  "minFreeStorageMB": 100
}
```

## 🚀 Step 6: Publish

Simply save the `update.json` file on your server (or commit it to your GitHub repo if using raw GitHub links).

That's it! Every installed instance of the Milk Cash app will automatically detect the change on their next background check, download the APK, verify the SHA-256 hash, and prompt the user to install the update seamlessly.

---

## 🧰 Advanced Admin Controls

You can control app behavior simply by changing fields in the `update.json` file:

- **Force Update**: Set `"forceUpdate": true`. The user will not be able to dismiss the update dialog and must install it to continue using the app.
- **Rollback**: If `1.1.0` has a critical bug, change `"status": "Rollback"` and set `"latestVersion": "1.0.0"`. The app will prompt users to downgrade to a stable version.
- **Maintenance Mode**: Set `"status": "Maintenance"` and optionally add `"maintenanceMessage": "Upgrading servers..."`. The app will block entry and show a full-screen maintenance message until you revert the status to "Active".
- **Phased Rollouts**: Set `"rolloutPercentage": 25`. Only 25% of users will receive the update prompt. Increase this safely over a few days.

## 🐛 Troubleshooting

- **App says "Corrupted APK"**: Ensure the `sha256` in your `update.json` exactly matches the hash of the file you uploaded.
- **App doesn't detect update**: Ensure `versionCode` in the JSON is strictly greater than the user's installed version code.
- **Direct Link**: Ensure your `apkUrl` is a *direct* download link. (If you paste the URL into a browser, it should instantly start downloading the file, not open a webpage).
