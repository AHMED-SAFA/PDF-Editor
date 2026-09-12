from fastapi import APIRouter, File, Form, HTTPException, UploadFile, status
from fastapi.responses import Response

from app.core.pdf_io import read_pdf_upload
from app.services.translate_pdf import translate_pdf
from app.services.translator import TranslationError

router = APIRouter(tags=["translate"])


@router.post("/api/translate-pdf")
async def translate_pdf_endpoint(
    file: UploadFile = File(...),
    source_language: str = Form(...),
    target_language: str = Form(...),
) -> Response:
    pdf_bytes = await read_pdf_upload(file)
    try:
        result = translate_pdf(pdf_bytes, source_language, target_language)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    except TranslationError as exc:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(exc)) from exc

    filename = (file.filename or "document.pdf").rsplit(".", 1)[0] + "-translated.pdf"
    return Response(
        content=result,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
