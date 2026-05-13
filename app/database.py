from pathlib import Path

from sqlmodel import SQLModel, Session, create_engine

# Import models so SQLModel metadata registers all tables
import app.models


# Create data directory if it does not exist
DATA_DIR = Path("data")
DATA_DIR.mkdir(exist_ok=True)

# SQLite database path
DATABASE_PATH = DATA_DIR / "ledger.db"

# SQLite connection URL
DATABASE_URL = f"sqlite:///{DATABASE_PATH}"

# Database engine
engine = create_engine(
    DATABASE_URL,
    echo=True,
)


def create_db_and_tables() -> None:
    """
    Creates all database tables registered in SQLModel metadata.
    """
    SQLModel.metadata.create_all(engine)


def get_session() -> Session:
    """
    Creates and returns a database session.
    """
    return Session(engine)