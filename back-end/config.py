# @author Rayane Rousseau
import os
import sys
import shutil
from typing import List, Optional


def _first_existing_path(paths: List[str]) -> Optional[str]:
    for candidate in paths:
        if candidate and os.path.exists(candidate):
            return candidate
    return None


def _resolve_tesseract_cmd() -> str:
    env_value = os.environ.get("TESSERACT_CMD")
    if env_value:
        return env_value

    if sys.platform == "win32":
        return r"C:\Program Files\Tesseract-OCR\tesseract.exe"

    return shutil.which("tesseract") or "/usr/bin/tesseract"


def _resolve_tessdata_prefix() -> str:
    env_value = os.environ.get("TESSDATA_PREFIX")
    if env_value:
        return env_value

    if sys.platform == "win32":
        return r"C:\tessdata"

    return _first_existing_path(
        [
            "/usr/share/tesseract/tessdata",
            "/usr/share/tesseract-ocr/5/tessdata",
            "/usr/share/tesseract-ocr/4.00/tessdata",
        ]
    ) or "/usr/share/tesseract/tessdata"


TESSERACT_CMD = _resolve_tesseract_cmd()
TESSDATA_PREFIX = _resolve_tessdata_prefix()
FFMPEG_PATH = os.environ.get(
    "FFMPEG_PATH",
    r"C:\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe" if sys.platform == "win32"
    else "ffmpeg",
)
UPLOAD_DIR = os.environ.get("UPLOAD_DIR", "uploads")
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///db.sqlite3")
