from app.services.pdf_text import extract_text
from app.services.pdf_write import text_to_pdf
from app.services.translator import translate_text


def translate_pdf(pdf_bytes: bytes, source_language: str, target_language: str) -> bytes:
    original = extract_text(pdf_bytes)
    translated = translate_text(original, source_language, target_language)
    return text_to_pdf(translated)
