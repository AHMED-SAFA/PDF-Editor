# PDF Editor APIs

FastAPI backend for the coding assessment:

- `POST /api/translate-pdf` — extract, translate, rebuild PDF
- `POST /editor/pdf/watermark` — stamp text on every page

A minimal Flutter client lives in `../flutter_app`.

## Setup

```bash
cd backend
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt
```

Fonts are in `app/assets/fonts` (Noto Sans + Noto Sans Bengali).

## Run the server

From the `backend` folder:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

## Postman

Import `postman/PDF_Editor.postman_collection.json`.

Set `baseUrl` to `http://127.0.0.1:8000`.

### Translate PDF

- Method: `POST`
- URL: `{{baseUrl}}/api/translate-pdf`
- Body: form-data
  - `file` (file) — PDF
  - `source_language` (text) — e.g. `en`
  - `target_language` (text) — e.g. `bn`
- Send, then **Save Response → Save to a file** (PDF)

### Watermark PDF

- Method: `POST`
- URL: `{{baseUrl}}/editor/pdf/watermark`
- Body: form-data
  - `file` (file)
  - `text` — e.g. `CONFIDENTIAL`
  - `position` — one of `top-left`, `top-center`, `top-right`, `center`, `bottom-left`, `bottom-center`, `bottom-right`
  - `opacity` — `0.0` to `1.0`, e.g. `0.25`
  - `color` — hex, e.g. `#FF0000`

## Flutter app

See `../flutter_app/README.md`. Point the app at this server (`10.0.2.2:8000` on the Android emulator).
