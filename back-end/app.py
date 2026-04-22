# @author Rayane Rousseau
import os
import re
import uuid
import subprocess
from contextlib import contextmanager
from datetime import datetime

import fitz
import spacy
import pytesseract
from PIL import Image
from flask import Flask, Blueprint, request, jsonify
from flask_cors import CORS
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from werkzeug.utils import secure_filename

from config import TESSERACT_CMD, TESSDATA_PREFIX, FFMPEG_PATH, UPLOAD_DIR, DATABASE_URL
from schema import Base, DocRecord, DocVersion

try:
    import whisper
except Exception:
    whisper = None

pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD
os.environ["TESSDATA_PREFIX"] = TESSDATA_PREFIX

os.makedirs(UPLOAD_DIR, exist_ok=True)

engine = create_engine(DATABASE_URL)
Base.metadata.create_all(engine)
_Session = sessionmaker(bind=engine)

try:
    nlp = spacy.load("fr_core_news_sm")
except Exception:
    nlp = spacy.blank("fr")

_whisper = whisper.load_model("base") if whisper else None

app = Flask(__name__)
CORS(app)

docs_bp = Blueprint("docs", __name__, url_prefix="/api/docs")
search_bp = Blueprint("search", __name__, url_prefix="/api/search")
assistant_bp = Blueprint("assistant", __name__, url_prefix="/api/assistant")
stats_bp = Blueprint("stats", __name__, url_prefix="/api")


# ── session context manager ──────────────────────────────────────────────────

@contextmanager
def db_session():
    session = _Session()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


# ── text processing ───────────────────────────────────────────────────────────

def sanitize_text(raw: str) -> str:
    cleaned = "".join(ch if (ch.isalnum() or ch.isspace()) else " " for ch in raw)
    return " ".join(cleaned.split())


def extract_keywords(corpus: list, query: str, top_n: int = 15) -> list:
    if not corpus:
        corpus = [query]
    combined = corpus + [query]
    vectorizer = TfidfVectorizer(max_features=500, ngram_range=(1, 1))
    vectorizer.fit(combined)
    import numpy as np
    tfidf_matrix = vectorizer.transform([query]).toarray()[0]
    ranked = sorted(
        enumerate(tfidf_matrix), key=lambda x: x[1], reverse=True
    )
    feature_names = vectorizer.get_feature_names_out()
    return [feature_names[i] for i, score in ranked[:top_n] if score > 0]


def refine_keywords(words: list) -> list:
    stopwords = nlp.Defaults.stop_words
    result = []
    for word in words:
        token = nlp(word)[0]
        if (
            token.pos_ in ("NOUN", "PROPN")
            and token.text.lower() not in stopwords
            and len(token.text) > 1
        ):
            result.append(token.text)
    return result


# ── media extraction ──────────────────────────────────────────────────────────

def extract_image_text(path: str) -> str:
    return pytesseract.image_to_string(Image.open(path), lang="fra")


def extract_pdf_text(path: str) -> str:
    pages_text = []
    doc = fitz.open(path)
    for page in doc:
        pix = page.get_pixmap(dpi=300)
        tmp = os.path.join(UPLOAD_DIR, f"_page_{uuid.uuid4().hex}.png")
        pix.save(tmp)
        pages_text.append(extract_image_text(tmp))
        os.remove(tmp)
    return "\n".join(pages_text)


def to_wav(mp3_path: str, wav_path: str) -> None:
    subprocess.run(
        [FFMPEG_PATH, "-y", "-i", mp3_path, wav_path],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=True,
    )


def transcribe(path: str) -> str:
    if _whisper is None:
        raise RuntimeError("Whisper is not installed. Install openai-whisper to transcribe audio.")
    wav = path.rsplit(".", 1)[0] + ".wav"
    to_wav(path, wav)
    result = _whisper.transcribe(wav, language="fr")
    os.remove(wav)
    return result["text"]


# ── helpers ───────────────────────────────────────────────────────────────────

def _doc_corpus():
    with db_session() as db:
        return [d.content for d in db.query(DocRecord).all()]


def _serialize_doc(doc, include_content=False):
    data = {
        "id": doc.id,
        "filename": doc.filename,
        "uploader": doc.uploader,
        "keywords": [k.strip() for k in doc.keywords.split(",") if k.strip()],
        "tags": [t.strip() for t in (doc.tags or "").split(",") if t.strip()],
        "uploaded_at": doc.uploaded_at.isoformat() if doc.uploaded_at else None,
        "versions": [
            {
                "version_number": v.version_number,
                "filename": v.filename,
                "keywords": [k.strip() for k in v.keywords.split(",") if k.strip()],
                "uploaded_at": v.uploaded_at.isoformat() if v.uploaded_at else None,
            }
            for v in doc.versions
        ],
    }
    if include_content:
        data["extracted_text"] = doc.content
    return data


# ── document routes ───────────────────────────────────────────────────────────

@docs_bp.route("/ingest", methods=["POST"])
def ingest_document():
    f = request.files.get("file")
    uploader = request.form.get("uploader", "anonymous")
    if not f:
        return jsonify({"error": "No file provided"}), 400

    filename = secure_filename(f.filename)
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""
    save_path = os.path.join(UPLOAD_DIR, f"{uuid.uuid4().hex}_{filename}")
    f.save(save_path)

    try:
        if ext in ("png", "jpg", "jpeg"):
            raw = extract_image_text(save_path)
        elif ext == "pdf":
            raw = extract_pdf_text(save_path)
        elif ext == "mp3":
            raw = transcribe(save_path)
        else:
            return jsonify({"error": f"Unsupported format: {ext}"}), 400
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500

    text = sanitize_text(raw)
    corpus = _doc_corpus()
    kws = refine_keywords(extract_keywords(corpus, text))
    kw_str = ", ".join(kws)
    now = datetime.utcnow()

    with db_session() as db:
        existing = db.query(DocRecord).filter_by(filename=filename).first()
        if existing is None:
            record = DocRecord(
                filename=filename,
                uploader=uploader,
                content=text,
                keywords=kw_str,
                uploaded_at=now,
            )
            db.add(record)
            db.flush()
            doc_id = record.id
        else:
            doc_id = existing.id

        last = (
            db.query(DocVersion)
            .filter_by(document_id=doc_id)
            .order_by(DocVersion.version_number.desc())
            .first()
        )
        version_num = (last.version_number + 1) if last else 1
        db.add(
            DocVersion(
                document_id=doc_id,
                version_number=version_num,
                filename=filename,
                content=text,
                keywords=kw_str,
                uploaded_at=now,
            )
        )

    return jsonify(
        {
            "filename": filename,
            "uploader": uploader,
            "keywords": kws,
            "extracted_text": text,
            "upload_timestamp": now.isoformat(),
            "version_number": version_num,
        }
    )


@docs_bp.route("/all", methods=["GET"])
def list_all():
    with db_session() as db:
        records = db.query(DocRecord).all()
        return jsonify([_serialize_doc(r, include_content=True) for r in records])


@docs_bp.route("/history", methods=["GET"])
def user_history():
    user = request.args.get("user", "")
    if not user:
        return jsonify({"error": "user parameter required"}), 400
    with db_session() as db:
        records = db.query(DocRecord).filter_by(uploader=user).all()
        return jsonify({"user": user, "documents": [_serialize_doc(r) for r in records]})


@docs_bp.route("/versions", methods=["GET"])
def document_versions():
    filename = request.args.get("filename", "")
    if not filename:
        return jsonify({"error": "filename parameter required"}), 400
    with db_session() as db:
        record = db.query(DocRecord).filter_by(filename=filename).first()
        if not record:
            return jsonify({"error": "Document not found"}), 404
        return jsonify(_serialize_doc(record))


@docs_bp.route("/tags", methods=["POST"])
def update_tags():
    data = request.get_json(silent=True) or {}
    doc_id = data.get("doc_id")
    tags = data.get("tags", [])
    if not doc_id:
        return jsonify({"error": "doc_id required"}), 400
    with db_session() as db:
        record = db.query(DocRecord).filter_by(id=doc_id).first()
        if not record:
            return jsonify({"error": "Document not found"}), 404
        record.tags = ", ".join(tags)
    return jsonify({"doc_id": doc_id, "tags": tags})


# ── search routes ─────────────────────────────────────────────────────────────

def _match_docs(db, keywords: list) -> list:
    records = db.query(DocRecord).all()
    return [
        _serialize_doc(r)
        for r in records
        if any(kw.lower() in r.keywords.lower() for kw in keywords)
    ]


def _semantic_search(db, query: str, top_n: int = 10) -> list:
    records = db.query(DocRecord).all()
    if not records:
        return []

    docs_text = [r.content or "" for r in records]
    vectorizer = TfidfVectorizer(max_features=1000, ngram_range=(1, 2))
    tfidf = vectorizer.fit_transform(docs_text + [query])
    doc_matrix = tfidf[:-1]
    query_vector = tfidf[-1]
    scores = cosine_similarity(doc_matrix, query_vector).ravel()

    ranked = sorted(
        enumerate(records),
        key=lambda item: float(scores[item[0]]),
        reverse=True,
    )
    return [
        {
            **_serialize_doc(record),
            "score": round(float(scores[idx]), 4),
        }
        for idx, record in ranked[:top_n]
        if float(scores[idx]) > 0
    ]


@search_bp.route("/query", methods=["POST"])
def query_search():
    audio = request.files.get("audio")
    if audio:
        tmp = os.path.join(UPLOAD_DIR, f"_q_{uuid.uuid4().hex}.mp3")
        audio.save(tmp)
        text_query = transcribe(tmp)
        os.remove(tmp)
    else:
        data = request.get_json(silent=True) or {}
        text_query = data.get("text", "")

    clean_query = sanitize_text(text_query)
    if not clean_query:
        return jsonify({"error": "text query required"}), 400

    corpus = _doc_corpus()
    kws = refine_keywords(extract_keywords(corpus, clean_query))

    with db_session() as db:
        matches = _semantic_search(db, clean_query)
    return jsonify({"extracted_keywords": kws, "results": matches})


@search_bp.route("/keywords", methods=["POST"])
def keyword_search():
    data = request.get_json(silent=True) or {}
    keywords = data.get("keywords", [])
    if not keywords:
        return jsonify({"error": "keywords list required"}), 400
    with db_session() as db:
        return jsonify(_match_docs(db, keywords))


# ── assistant routes ──────────────────────────────────────────────────────────

@assistant_bp.route("/compare", methods=["POST"])
def flux_compare():
    data = request.get_json(silent=True) or {}
    doc1 = data.get("doc1", "")
    doc2 = data.get("doc2", "")
    return jsonify(
        {
            "message": "Flux assistant comparison is not yet available.",
            "doc1_preview": doc1[:200],
            "doc2_preview": doc2[:200],
        }
    )


# ── stats routes ──────────────────────────────────────────────────────────────

@stats_bp.route("/stats", methods=["GET"])
def get_stats():
    with db_session() as db:
        records = db.query(DocRecord).all()
        total_docs = len(records)
        total_versions = sum(len(r.versions) for r in records)
        freq: dict = {}
        for r in records:
            for kw in r.keywords.split(","):
                word = kw.strip()
                if word:
                    freq[word] = freq.get(word, 0) + 1
        top = sorted(freq.items(), key=lambda x: x[1], reverse=True)[:10]

    return jsonify(
        {
            "total_documents": total_docs,
            "total_versions": total_versions,
            "top_keywords": [{"keyword": k, "count": c} for k, c in top],
        }
    )


# ── register blueprints ───────────────────────────────────────────────────────

app.register_blueprint(docs_bp)
app.register_blueprint(search_bp)
app.register_blueprint(assistant_bp)
app.register_blueprint(stats_bp)

if __name__ == "__main__":
    app.run(debug=True)
