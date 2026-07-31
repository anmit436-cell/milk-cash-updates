# Publishing Update v1.2.2

I've already updated your `update.json`, `pubspec.yaml`, built the NEW APK, and generated the new SHA256 checksum. You just need to publish it so your users receive the OTA update which includes the new Tally Cash System!

Follow these exact steps:

## 1. Commit and Push the Code
*(Skip this step if you don't use Git locally)*
Open your terminal and run:
```bash
git add pubspec.yaml update.json lib/screens/counter/widgets/tally_cash_panel.dart
git commit -m "feat: updated tally cash panel to difference between expected and counted cash"
git push origin main
```

## 2. Create the GitHub Release
1. Go to your repository: **anmit436-cell/milk-cash-updates** on GitHub.
2. Click on **Releases** on the right side of the repository page.
3. Click **Draft a new release**.
4. In the **Choose a tag** dropdown, type exactly: `v1.2.2` and click "Create new tag: v1.2.2".
5. Set the **Release title** to: `Version 1.2.2`
6. In the description, you can paste:
   ```text
   - Updated Tally Cash Panel to compute difference between Expected Cash and Counted Cash.
   ```

## 3. Upload the APK
1. At the bottom of the release page, you will see a box that says **"Attach binaries by dropping them here or selecting them"**.
2. Drag and drop the generated `app-release.apk` file located precisely at:
   `C:\Users\Ruchi Mishra\Desktop\MISHRA MILK CASH\build\app\outputs\flutter-apk\app-release.apk`
3. Wait for the upload to finish completely.

## 4. Publish
Click the green **Publish release** button.

## 5. Update your remote update.json (if necessary)
If your `update.json` is manually hosted on GitHub or another server, make sure to upload the updated `update.json` file found at:
`C:\Users\Ruchi Mishra\Desktop\MISHRA MILK CASH\update.json`
to your server/repository so the app knows version 1.2.2 is available.

🎉 **You're done!** 
When you update your server's `update.json` with the new one I just made, your app will automatically grab `v1.2.2` and prompt users with the update dialog within seconds!
