import shutil
import uuid
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile

router = APIRouter()

UPLOAD_DIR = Path("static/uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    """
    Upload a file and return its URL.
    """
    try:
        # Generate a unique filename using UUID
        extension = Path(file.filename).suffix if file.filename else ""
        filename = f"{uuid.uuid4()}{extension}"
        file_path = UPLOAD_DIR / filename

        # Save the file
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Construct the URL
        # Assuming the app is mounted at root, and static files are served at /static
        # We need to use the request base URL, but for simplicity we can return a relative path
        # or construct a full URL if we knew the domain.
        # Let's return the relative path for now, frontend can prepend base URL.
        # OR: Return full URL if we can get it from request (not passed here).
        # Better: Return the path that can be appended to API_BASE_URL.
        
        # However, static files are usually served from a separate path.
        # Let's say we mount /static/uploads to /static/uploads
        
        file_url = f"/static/uploads/{filename}"
        
        return {"url": file_url}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")
