# wifREMOTE

A cross-platform Flutter application for local network discovery, real-time bandwidth monitoring, and QoS limit management.

## Architecture

This application employs a **Router Plugin Architecture** to ensure compatibility across a wide variety of routers.
- **Generic UPnP IGD Plugin:** Included by default, supports fetching global bandwidth but lacks QoS support (as it's not standardized in UPnP).
- **Router Manager Service:** Dynamically detects and manages the correct plugin for your specific router model.

## Getting Started

Because you might not have Flutter installed in your current PATH or environment, the core application logic has been written to the `lib/` directory and `pubspec.yaml`.

### 1. Install Flutter
If you haven't already, install the Flutter SDK from: [flutter.dev](https://flutter.dev/docs/get-started/install)

### 2. Generate Platform Folders
Once Flutter is installed, open a terminal in this directory (`c:\Users\Redal\wifREMOTE`) and run:
```bash
flutter create .
```
*Note: This will generate the `android`, `ios`, `web`, and `windows` folders required to build the app, while preserving the existing `lib/` and `pubspec.yaml` files.*

### 3. Add Android Permissions
To allow the app to scan the local Wi-Fi network on Android, you must add the following permissions to the generated `android/app/src/main/AndroidManifest.xml` file, right before the `<application>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<!-- Required for some local network discovery libraries -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 4. Run the App
Connect your Android device or start an emulator, and run:
```bash
flutter run
```

## Upcoming Features
- **Plugin Store:** A UI module to download specific router plugins (e.g., FritzBox TR-064, AsusWRT, DD-WRT) for advanced QoS support.
