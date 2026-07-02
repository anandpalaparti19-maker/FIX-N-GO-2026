## Step 1 — Generate a release keystore (run once, keep the file safe)
##
## WINDOWS (PowerShell):
##   keytool -genkey -v -keystore fixngo-technician-release.jks `
##     -alias fixngo-technician `
##     -keyalg RSA -keysize 2048 `
##     -validity 10000 `
##     -storetype JKS
##
## When prompted:
##   - First and Last Name:  Fix-N-Go Technician
##   - Organizational Unit: Engineering
##   - Organization:        Fix-N-Go
##   - City/State/Country:  Your city, state, IN
##   - Set a STRONG password for both keystore and key alias
##
## STORE THE .jks FILE SECURELY — never commit it to Git.
## Add fixngo-technician-release.jks to apps/technician_app/android/.gitignore

## Step 2 — Create key.properties (do NOT commit this file)
##
## Create:  apps/technician_app/android/key.properties
## Content (replace with your actual values):
##
##   storePassword=YOUR_KEYSTORE_PASSWORD
##   keyPassword=YOUR_KEY_PASSWORD
##   keyAlias=fixngo-technician
##   storeFile=../fixngo-technician-release.jks

## Step 3 — Build the signed release APK
##
##   cd apps/technician_app
##   flutter build apk --release
##
## Output: build/app/outputs/flutter-apk/app-release.apk
##
## For AAB (Play Store upload):
##   flutter build appbundle --release
## Output: build/app/outputs/bundle/release/app-release.aab

## Step 4 — Verify the signature
##   apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk

## CI/CD note:
##   Store storePassword, keyPassword as CI secrets (GitHub Secrets, etc.)
##   Reconstruct key.properties from env vars in the pipeline:
##
##   echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
##   echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
##   echo "keyAlias=fixngo-technician" >> android/key.properties
##   echo "storeFile=../fixngo-technician-release.jks" >> android/key.properties
