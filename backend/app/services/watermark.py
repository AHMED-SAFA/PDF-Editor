import html
from typing import Literal

import pymupdf

from app.core.fonts import BODY_CSS, font_archive

Position = Literal[
    "top-left",
    "top-center",
    "top-right",
    "center",
    "bottom-left",
    "bottom-center",
    "bottom-right",
]

POSITIONS: tuple[str, ...] = (
    "top-left",
    "top-center",
    "top-right",
    "center",
    "bottom-left",
    "bottom-center",
    "bottom-right",
)


def _align(position: str) -> str:
    if position.endswith("left"):
        return "left"
    if position.endswith("right"):
        return "right"
    return "center"


def _watermark_rect(page: pymupdf.Page, position: str) -> pymupdf.Rect:
    rect = page.rect
    box_w = min(rect.width * 0.72, 420)
    box_h = 56 if position != "center" else 72
    margin = 28

    x_left = rect.x0 + margin
    x_right = rect.x1 - margin - box_w
    x_center = rect.x0 + (rect.width - box_w) / 2
    y_top = rect.y0 + margin
    y_bottom = rect.y1 - margin - box_h
    y_center = rect.y0 + (rect.height - box_h) / 2

    coords = {
        "top-left": (x_left, y_top),
        "top-center": (x_center, y_top),
        "top-right": (x_right, y_top),
        "center": (x_center, y_center),
        "bottom-left": (x_left, y_bottom),
        "bottom-center": (x_center, y_bottom),
        "bottom-right": (x_right, y_bottom),
    }
    x, y = coords[position]
    return pymupdf.Rect(x, y, x + box_w, y + box_h)


def apply_text_watermark(
    pdf_bytes: bytes,
    text: str,
    position: str,
    opacity: float,
    color: str,
) -> bytes:
    css = BODY_CSS + f"""
    .mark {{
        color: {color};
        font-size: 22pt;
        font-weight: 600;
        text-align: {_align(position)};
        margin: 0;
    }}
    """
    markup = f'<p class="mark">{html.escape(text)}</p>'

    with pymupdf.open(stream=pdf_bytes, filetype="pdf") as doc:
        for page in doc:
            page.insert_htmlbox(
                _watermark_rect(page, position),
                markup,
                css=css,
                archive=font_archive(),
                opacity=opacity,
                overlay=True,
            )
        return doc.tobytes()
