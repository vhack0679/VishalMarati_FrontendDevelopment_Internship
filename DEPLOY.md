# Deployment Guide

## Firebase Hosting (Web)

1.  **Login to Firebase**:
    ```bash
    firebase login
    ```

2.  **Initialize Hosting**:
    ```bash
    firebase init hosting
    ```
    - Select your project.
    - Public directory: `build/web`
    - Configure as single-page app: **Yes**
    - Overwrite index.html: **No** (if asked)

3.  **Build Web App**:
    ```bash
    flutter build web --release
    ```

4.  **Deploy**:
    ```bash
    firebase deploy --only hosting
    ```

## Android Build (APK/AAB)

1.  **Update Version**:
    Update `version` in `pubspec.yaml` (e.g., `1.0.0+1`).

2.  **Build APK**:
    ```bash
    flutter build apk --release
    ```
    Output: `build/app/outputs/flutter-apk/app-release.apk`

3.  **Build App Bundle (AAB)** (for Play Store):
    ```bash
    flutter build appbundle --release
    ```
    Output: `build/app/outputs/bundle/release/app-release.aab`

## Video Walkthrough Checklist

Use this checklist while recording your 5-10 minute walkthrough:

1.  **Intro**: Briefly mention your name and the tech stack (Flutter, GetX, Clean Arch).
2.  **Auth Flow**:
    - Show Login Screen.
    - Enter Test Phone Number.
    - Enter OTP.
    - Show successful transition to Home Screen.
3.  **List View**:
    - Scroll through the list.
    - Show "Load More" or infinite scroll if applicable (or just list rendering).
4.  **Create Object**:
    - Click "+" button.
    - Enter Name.
    - Enter Invalid JSON to show validation error.
    - Enter Valid JSON.
    - Submit and show success message.
5.  **Detail View**:
    - Tap on an object.
    - Show pretty-printed JSON.
6.  **Update Object**:
    - Click Edit.
    - Change Name or Data.
    - Save and show update.
7.  **Delete Object**:
    - Click Delete.
    - Confirm dialog.
    - Show item removed from list (Optimistic UI).
8.  **Code Overview**:
    - Briefly show Project Structure in IDE.
    - Show `AuthController` or `ApiService` code.
    - Show Unit Tests running (`flutter test`).
9.  **Conclusion**: Mention responsive design (toggle web/mobile view if possible) and wrap up.
