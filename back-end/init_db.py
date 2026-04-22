# @author Rayane Rousseau
from sqlalchemy import create_engine
from config import DATABASE_URL
from schema import Base

engine = create_engine(DATABASE_URL)
Base.metadata.create_all(engine)
print("DocFlow database initialized.")
