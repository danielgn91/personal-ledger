from app.database import LedgerDatabase
from pathlib import Path
from platformdirs import user_documents_dir

INVALID_CHARS = '<>:"/\\|?*'

class InvalidLedgerError(Exception):
    pass

class ApplicationState:

    def __init__(self):
        self.ledger_db: LedgerDatabase | None = None
        self.language: str = "pt_BR"
        self.ledger_folder = Path(user_documents_dir()) / "Ledgers"
    
    def create_ledger(self, name: str):
        path = self.get_ledger_path(name)
        self.close_ledger()
        db = LedgerDatabase(path)
        db.create_tables()
        self.ledger_db = db

    def get_ledger_path(self, name: str) -> Path:
        name = self.validate_ledger_name(name)
        if not name.lower().endswith(".db"):
            name += ".db"
        
        self.ledger_folder.mkdir(
            parents=True,
            exist_ok=True
        )

        return self.ledger_folder / name

    def validate_ledger_name(self, name: str) -> str:
        name = name.strip()

        if not name:
            raise InvalidLedgerError(
                "Ledger name cannot be empty."
            )

        if any(char in name for char in INVALID_CHARS):
            raise InvalidLedgerError(
                "Ledger name contains invalid characters."
            )

        return name


    def open_ledger(self, path: Path):
        if not path.exists():
            print(path)
            raise InvalidLedgerError(
                "Ledger file does not exist."
            )
        
        if path.suffix.lower() != ".db":
            raise InvalidLedgerError(
                "Invalid ledger file."
            )

        self.close_ledger()
        self.ledger_db = LedgerDatabase(path)

    def close_ledger(self):
        self.ledger_db = None

    @property
    def has_ledger(self) -> bool:
        return self.ledger_db is not None


application = ApplicationState()