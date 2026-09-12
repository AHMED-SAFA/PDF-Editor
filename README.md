# PDF Editor

A full-stack PDF utility with a Python FastAPI backend and a Flutter client.
The project provides two operations:

- Translate the text of a PDF into another language.
- Add a configurable text watermark to every page of a PDF.

The Flutter app sends the selected PDF to the backend, receives the generated
PDF, saves it in the app documents directory, and opens it with the device's
default PDF viewer.

## Features

### PDF translation

- Select a PDF from the device.
- Choose a source and target language.
- Extract text from the PDF.
- Translate the extracted text through Google Translate, with MyMemory as a
  fallback.
- Generate a new PDF using embedded Unicode fonts.
- Save and open the translated result automatically.

The Flutter client currently exposes these languages:

| Code | Language  |
| ---- | --------- |
| `en` | English   |
| `bn` | Bangla    |
| `hi` | Hindi     |
| `ar` | Arabic    |
| `fr` | French    |
| `es` | Spanish   |

### PDF watermarking

- Select a PDF from the device.
- Enter watermark text.
- Select one of seven positions.
- Set opacity from `0.0 - 1.0``.
- Enter a 3-digit or 6-digit hexadecimal color.
- Apply the watermark to every page.
- Save and open the watermarked result automatically.

Supported positions:

`top-left`, `top-center`, `top-right`, `center`, `bottom-left`,
`bottom-center`, `bottom-right`

## Project Structure

```text
.
├── backend/
│   ├── app/
│   │   ├── api/                  # FastAPI route definitions
│   │   ├── assets/fonts/         # Noto Sans font files used in PDFs
│   │   ├── core/                 # Configuration, fonts, and PDF I/O
│   │   └── services/             # Translation, extraction, writing, watermarking
│   ├── postman/                  # Postman collection
│   ├── DESIGN.md                 # Backend design notes
│   ├── README.md                 # Backend-specific instructions
│   └── requirements.txt
├── flutter_app/
│   ├── lib/
│   │   ├── core/                 # API client, configuration, picker, file saving
│   │   └── features/             # Translation and watermark screens
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md                 # Flutter-specific instructions
└── README.md
```

## How It Works

```text
Flutter app
		│
		│ multipart/form-data HTTP request
		▼
FastAPI backend
		├── /api/translate-pdf
		│     ├── Extract PDF text with PyMuPDF
		│     ├── Translate text using Google / MyMemory
		│     └── Build a new PDF with embedded fonts
		│
		└── /editor/pdf/watermark
					└── Draw text on every original PDF page
		│
		▼
PDF response
		│
		▼
Flutter saves and opens the generated file
```

## Requirements

- Python 3.10 or newer recommended.
- Flutter SDK with Dart 3.3 or newer.
- Android Studio or a desktop Flutter target, depending on the target
  platform.
- Internet access for PDF translation.
- A PDF with an extractable text layer for translation.

## Backend Setup

Open a terminal in the repository root and create a Python virtual environment:

### Bash Command Prompt

```bash
cd backend
python -m venv .venv
source .venv/Scripts/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

The required fonts are included in `backend/app/assets/fonts`. No separate
font download is required.

## Flutter Setup

Open a second terminal:

```bash
cd flutter_app
flutter pub get
```

The repository already contains the Flutter platform folders. If Flutter
platform files need to be regenerated in a fresh checkout, run:

```bash
flutter create . --project-name pdf_editor_app
flutter pub get
```

Keep the existing `lib/` implementation when regenerating platform files.

## Running the Complete Project

### 1. Start the backend

From `backend/`:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend will be available at:

- API base URL: `http://127.0.0.1:8000`
- Interactive Swagger documentation: `http://127.0.0.1:8000/docs`
- ReDoc documentation: `http://127.0.0.1:8000/redoc`

### 2. Set the Flutter API URL

Edit `flutter_app/lib/core/api_config.dart` and select the URL appropriate for
the device running the app:

| Runtime                          | Base URL                |
| -------------------------------- | ----------------------- |
| Android emulator                 | `http://10.0.2.2:8000`  |
| iOS simulator                    | `http://127.0.0.1:8000` |
| Windows, macOS, or Linux desktop | `http://127.0.0.1:8000` |

### 3. Run Flutter

```bash
cd flutter_app
flutter devices
flutter run
or
flutter run -d chrome
```

In the app:

1. Open **Translate** or **Watermark** from the bottom navigation.
2. Browse for a PDF.
3. Enter the operation-specific options.
4. Submit the request.
5. Open the generated PDF from the success message.

## API Reference

All endpoints return `application/pdf` on success. Requests use
`multipart/form-data`.

### Translate PDF

```http
POST /api/translate-pdf
```

Form fields:

| Field             | Type | Required | Description                            |
| ----------------- | ---- | -------- | -------------------------------------- |
| `file`            | file | Yes      | Source PDF                             |
| `source_language` | text | Yes      | Source language code, for example `en` |
| `target_language` | text | Yes      | Target language code, for example `bn` |

The response filename is based on the input filename and ends with
`-translated.pdf`.

### Watermark PDF

```http
POST /editor/pdf/watermark
```

Form fields:

| Field      | Type   | Required | Description                          |
| ---------- | ------ | -------- | ------------------------------------ |
| `file`     | file   | Yes      | Source PDF                           |
| `text`     | text   | Yes      | Watermark text                       |
| `position` | text   | Yes      | One of the seven supported positions |
| `opacity`  | number | Yes      | Value from `0.0` to `1.0`            |
| `color`    | text   | Yes      | Hex color such as `#FF0000`          |

The response filename is based on the input filename and ends with
`-watermarked.pdf`.

### Error responses

| Status | Meaning                                        |
| ------ | ---------------------------------------------- |
| `400`  | Invalid form values or no extractable PDF text |
| `422`  | Missing or malformed request fields            |
| `413`  | Uploaded PDF is larger than 20 MiB             |
| `502`  | Translation providers failed                   |

## Configuration

Backend settings use the `PDF_EDITOR_` environment variable prefix. The
available settings are:

| Environment variable          | Default           | Purpose                            |
| ----------------------------- | ----------------- | ---------------------------------- |
| `PDF_EDITOR_APP_NAME`         | `PDF Editor APIs` | FastAPI application name           |
| `PDF_EDITOR_MAX_UPLOAD_BYTES` | `20971520`        | Intended upload size limit, 20 MiB |
| `PDF_EDITOR_CORS_ORIGINS`     | `[*]`             | Allowed CORS origins               |

Translation language codes are normalized to their short form. For example,
`en-US` becomes `en`.

## Testing With Postman

Import `backend/postman/PDF_Editor.postman_collection.json` into Postman.

Set the collection variable `baseUrl` to:

```text
http://127.0.0.1:8000
```

The collection contains requests for both PDF operations. Since the responses
are binary PDF files, use Postman's **Save Response** option to save a result
to disk.

## Architecture

### Backend

- `app/main.py` creates the FastAPI application, configures CORS, and registers
  both routers.
- `app/api/` validates request fields and converts service errors into HTTP
  responses.
- `app/services/pdf_text.py` extracts text with PyMuPDF.
- `app/services/translator.py` translates text in chunks and provides the
  Google/MyMemory fallback chain.
- `app/services/pdf_write.py` rebuilds translated text into a PDF.
- `app/services/watermark.py` draws escaped watermark HTML on every page.
- `app/core/fonts.py` provides the embedded Noto Sans font resources used for
  Latin and Bangla output.

### Flutter

- `lib/core/api_client.dart` sends multipart requests and reads PDF response
  bytes and filenames.
- `lib/core/api_config.dart` stores the backend base URL.
- `lib/core/pdf_picker_field.dart` restricts selection to PDF files.
- `lib/core/save_pdf.dart` writes the response to the app documents directory
  and opens it with `open_filex`.
- `lib/features/translate/` contains the translation screen and language
  controls.
- `lib/features/watermark/` contains the watermark screen and its controls.

## Screenshots

The following placeholders are intentionally left for project screenshots.
Replace each placeholder with a GitHub image link after adding images to the
repository, for example `docs/screenshots/translate-screen.png`.

### Main screen

<!-- SCREENSHOT PLACEHOLDER: Add the Flutter app home screen here. -->

> **Screenshot placeholder:** Add the Flutter home screen here, showing the
> Translate and Watermark tabs.

### PDF translation

<!-- SCREENSHOT PLACEHOLDER: Add the translation screen here. -->

> **Screenshot placeholder:** Add the translation screen here, showing PDF
> selection, source language, target language, and the Translate PDF button.

### PDF watermark

<!-- SCREENSHOT PLACEHOLDER: Add the watermark screen here. -->

> **Screenshot placeholder:** Add the watermark screen here, showing watermark
> text, position, opacity, color, and submit controls.

### Generated PDF

<!-- SCREENSHOT PLACEHOLDER: Add an output PDF preview here. -->

> **Screenshot placeholder:** Add an example translated or watermarked PDF
> output here.

## Additional Documentation

- [Backend README](backend/README.md)
- [Backend design notes](backend/DESIGN.md)
- [Flutter README](flutter_app/README.md)
- [Postman collection](backend/postman/PDF_Editor.postman_collection.json)
