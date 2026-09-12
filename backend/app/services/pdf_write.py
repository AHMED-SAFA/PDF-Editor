import html
import io

import pymupdf

from app.core.fonts import BODY_CSS, font_archive


def text_to_pdf(text: str) -> bytes:
    paragraphs = [
        f"<p>{html.escape(block)}</p>"
        for block in text.split("\n")
        if block.strip()
    ]
    if not paragraphs:
        paragraphs = ["<p></p>"]

    story = pymupdf.Story(
        "<body>" + "".join(paragraphs) + "</body>",
        user_css=BODY_CSS,
        archive=font_archive(),
    )

    buffer = io.BytesIO()
    writer = pymupdf.DocumentWriter(buffer)
    mediabox = pymupdf.paper_rect("a4")
    content_box = mediabox + (48, 48, -48, -48)

    more = True
    while more:
        device = writer.begin_page(mediabox)
        more, _filled = story.place(content_box)
        story.draw(device)
        writer.end_page()
    writer.close()
    return buffer.getvalue()
