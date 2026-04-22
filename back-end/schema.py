# @author Rayane Rousseau
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime

Base = declarative_base()


class DocRecord(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=False)
    uploader = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    keywords = Column(Text, nullable=False)
    tags = Column(Text, default="")
    uploaded_at = Column(DateTime, default=datetime.utcnow)
    versions = relationship(
        "DocVersion", back_populates="document", cascade="all, delete-orphan"
    )


class DocVersion(Base):
    __tablename__ = "document_versions"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id"), nullable=False)
    version_number = Column(Integer, nullable=False)
    filename = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    keywords = Column(Text, nullable=False)
    uploaded_at = Column(DateTime, default=datetime.utcnow)
    document = relationship("DocRecord", back_populates="versions")
