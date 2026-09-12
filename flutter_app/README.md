# PDF Editor — Flutter client

- Translate PDF → `POST /api/translate-pdf`
- Watermark PDF → `POST /editor/pdf/watermark`

## Run

```bash
flutter create . --project-name pdf_editor_app
flutter pub get
flutter run
```

## API URL

Edit `lib/core/api_config.dart`:

| Device | Base URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator / desktop | `http://127.0.0.1:8000` |
