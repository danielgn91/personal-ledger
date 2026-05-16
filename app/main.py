from app.database import LedgerDatabase

db = LedgerDatabase("data/test_ledger.db")
db.create_tables()

print("Database initialized.")