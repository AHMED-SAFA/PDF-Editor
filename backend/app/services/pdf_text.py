import pymupdf


def extract_text(pdf_bytes: bytes) -> str:
    with pymupdf.open(stream=pdf_bytes, filetype="pdf") as doc:
        pages = [page.get_text("text").strip() for page in doc]
    text = "\n\n".join(part for part in pages if part).strip()
    if not text:
        raise ValueError("No extractable text was found in this PDF.")
    return text
