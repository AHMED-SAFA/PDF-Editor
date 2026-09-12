from functools import lru_cache

import pymupdf

from app.core.config import settings

LATIN_FONT = "NotoSans-Regular.ttf"
BENGALI_FONT = "NotoSansBengali-Regular.ttf"

BODY_CSS = f"""
@font-face {{
    font-family: AppSans;
    src: url({LATIN_FONT});
}}
@font-face {{
    font-family: AppSans;
    src: url({BENGALI_FONT});
}}
body {{
    font-family: AppSans, sans-serif;
    font-size: 12pt;
    line-height: 1.45;
    color: #111111;
}}
p {{
    margin: 0 0 10px 0;
}}
"""


@lru_cache(maxsize=1)
def font_archive() -> pymupdf.Archive:
    return pymupdf.Archive(str(settings.fonts_dir))


def require_fonts() -> None:
    missing = [
        name
        for name in (LATIN_FONT, BENGALI_FONT)
        if not (settings.fonts_dir / name).exists()
    ]
    if missing:
        raise RuntimeError(
            "Missing font files in app/assets/fonts: " + ", ".join(missing)
        )
