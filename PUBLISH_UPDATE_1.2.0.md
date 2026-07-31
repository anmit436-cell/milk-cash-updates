# Publishing Update v1.2.0

I've already updated your `update.json`, `pubspec.yaml`, built the APK, and generated the SHA256 checksum. You just need to publish it so your users receive the OTA update!

Follow these exact steps:

## 1. Commit and Push the Code
Open your terminal and run:
```bash
git add pubspec.yaml update.json
git commit -m "chore: bump version to 1.2.0 and update release JSON"
git push origin main
```
*(If your branch is named differently, use your branch name instead of `main`)*

## 2. Create the GitHub Release
1. Go to your repository: **anmit436-cell/milk-cash-updates** on GitHub.
2. Click on **Releases** on the right side of the repository page.
3. Click **Draft a new release**.
4. In the **Choose a tag** dropdown, type exactly: `v1.2.0` and click "Create new tag: v1.2.0".
5. Set the **Release title** to: `Version 1.2.0`
6. In the description, you can paste:
   ```text
   - Updated numeric keyboard UI and behavior
   - Added brand new dashboard
   - New reporting system
   - Fixed alignment issues on small screens
   ```

## 3. Upload the APK
1. At the bottom of the release page, you will see an box that says **"Attach binaries by dropping them here or selecting them"**.
2. Drag and drop the generated `app-release.apk` file located precisely at:
   `C:\Users\Ruchi Mishra\Desktop\MISHRA MILK CASH\build\app\outputs\flutter-apk\app-release.apk`
3. Wait for the upload to finish completely.

## 4. Publish
Click the green **Publish release** button.

🎉 **You're done!** 
The OTA update is now live. Whenever your users open the Milk Cash app, it will automatically fetch `update.json`, detect `v1.2.0`, download the APK, verify the SHA256 checksum, and seamlessly prompt the user to install the update.
