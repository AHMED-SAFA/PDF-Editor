import re

from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from fastapi.responses import Response

from app.core.pdf_io import read_pdf_upload
from app.services.watermark import POSITIONS, apply_text_watermark

router = APIRouter(tags=["watermark"])
HEX_COLOR = re.compile(r"^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")


@router.post("/editor/pdf/watermark")
async def watermark_pdf_endpoint(
    file: UploadFile = File(...),
    text: str = Form(...),
    position: str = Form(...),
    opacity: float = Form(...),
    color: str = Form(...),
) -> Response:
    if not text.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="text is required.")
    if position not in POSITIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"position must be one of: {', '.join(POSITIONS)}",
        )
    if not 0.0 <= opacity <= 1.0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="opacity must be between 0.0 and 1.0.",
        )
    if not HEX_COLOR.match(color.strip()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail='color must be a hex value such as "#FF0000".',
        )

    pdf_bytes = await read_pdf_upload(file)
    result = apply_text_watermark(
        pdf_bytes,
        text=text.strip(),
        position=position,
        opacity=opacity,
        color=color.strip(),
    )
    filename = (file.filename or "document.pdf").rsplit(".", 1)[0] + "-watermarked.pdf"
    return Response(
        content=result,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
