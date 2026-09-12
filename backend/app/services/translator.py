from deep_translator import GoogleTranslator, MyMemoryTranslator

MAX_GOOGLE_CHUNK = 4000
MAX_MYMEMORY_CHUNK = 450

MYMEMORY_LOCALES = {
    "en": "en-GB",
    "bn": "bn-IN",
    "hi": "hi-IN",
    "ar": "ar-SA",
    "es": "es-ES",
    "fr": "fr-FR",
    "de": "de-DE",
}


class TranslationError(RuntimeError):
    pass


def _short_code(language: str) -> str:
    return language.strip().lower().replace("_", "-").split("-")[0]


def _chunks(text: str, size: int) -> list[str]:
    parts: list[str] = []
    remaining = text
    while remaining:
        if len(remaining) <= size:
            parts.append(remaining)
            break
        split_at = remaining.rfind("\n", 0, size)
        if split_at < size // 2:
            split_at = remaining.rfind(" ", 0, size)
        if split_at < 1:
            split_at = size
        parts.append(remaining[:split_at])
        remaining = remaining[split_at:].lstrip()
    return parts


def _run(translator: object, text: str, size: int) -> str:
    translated: list[str] = []
    for chunk in _chunks(text, size):
        translated.append(translator.translate(chunk))
    return "\n".join(translated)


def translate_text(text: str, source_language: str, target_language: str) -> str:
    source = _short_code(source_language)
    target = _short_code(target_language)
    if not source or not target:
        raise TranslationError("source_language and target_language are required.")
    if source == target:
        return text

    errors: list[str] = []
    try:
        return _run(
            GoogleTranslator(source=source, target=target),
            text,
            MAX_GOOGLE_CHUNK,
        )
    except Exception as exc:  # noqa: BLE001
        errors.append(f"Google: {exc}")

    try:
        return _run(
            MyMemoryTranslator(
                source=MYMEMORY_LOCALES.get(source, source),
                target=MYMEMORY_LOCALES.get(target, target),
            ),
            text,
            MAX_MYMEMORY_CHUNK,
        )
    except Exception as exc:  # noqa: BLE001
        errors.append(f"MyMemory: {exc}")

    raise TranslationError("Translation failed. " + " | ".join(errors))
