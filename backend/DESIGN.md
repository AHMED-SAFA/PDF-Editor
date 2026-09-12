# Design notes

The API is a thin FastAPI layer over small services. Routers only validate
uploads and form fields. PDF work lives in `app/services` so either endpoint
can be reused from another app or a CLI later.

**Libraries.** PyMuPDF extracts text, writes the translated document, and
draws watermarks. It is a practical choice on Windows: one dependency, Unicode
fonts via `@font-face`, and HTML layout through `Story` / `insert_htmlbox`.
Translation is `deep-translator`: Google first, MyMemory as a free fallback
(needed when Google rate-limits). No paid API key. Swap `translator.py` if you
later want a billed provider.

**Bangla.** Output PDFs embed Noto Sans Bengali (and Noto Sans for Latin).
PyMuPDF’s HTML writer uses HarfBuzz-style shaping, which keeps conjuncts
readable. Watermark text uses the same font stack, so `bn` works as source or
target and as watermark copy.

**Limits.** Translation needs outbound network access and can fail if Google
throttles the free endpoint. Rebuilt PDFs are flowing text on A4 pages; they
do not clone the source layout, fonts, or images. Scanned PDFs with no text
layer cannot be translated.
