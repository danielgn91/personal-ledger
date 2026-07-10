from app.database import LedgerDatabase
from pathlib import Path

class ApplicationState:

    def __init__(self):
        self.ledger_db: LedgerDatabase | None = None
        self.language: str = "pt-BR"

    def create_ledger(self, path: Path):
        self.close_ledger()
        db = LedgerDatabase(path)
        db.create_tables()
        self.ledger_db = db

    def open_ledger(self, path: Path):
        self.close_ledger()
        self.ledger_db = LedgerDatabase(path)

    def close_ledger(self):
        self.ledger_db = None

    @property
    def has_ledger(self) -> bool:
        return self.ledger_db is not None


application = ApplicationState()