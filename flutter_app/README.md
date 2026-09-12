# PDF Editor — Flutter client

Minimal UI for:

- Translate PDF → `POST /api/translate-pdf`
- Watermark PDF → `POST /editor/pdf/watermark`

## Run

Flutter SDK is required. From this folder:

```bash
flutter create . --project-name pdf_editor_app
flutter pub get
flutter run
```

`flutter create .` only generates Android/iOS/Windows folders. Keep the existing `lib/` files.

## API URL

Edit `lib/core/api_config.dart`:

| Device | Base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator / desktop | `http://127.0.0.1:8000` |
| Physical phone | `http://YOUR_LAN_IP:8000` |

Start the Python server first (`backend/README.md`). On a real phone, the PC and phone must be on the same Wi-Fi, and the server should bind to `0.0.0.0`.

HTTP (not HTTPS) needs cleartext enabled on Android. After `flutter create .`, set this on the `<application>` tag in `android/app/src/main/AndroidManifest.xml`:

```xml
android:usesCleartextTraffic="true"
```
