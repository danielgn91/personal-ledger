from datetime import date

from app.database import LedgerDatabase

from app.services.account_service import (
    create_account,
    change_account_parent
)

from app.services.transaction_service import (
    create_transaction,
)

from app.models.enums import (
    AccountType,
    NormalBalance,
)

from app.schemas.transactions import Posting

print("db = LedgerDatabase(r'.\data\personal-ledger.db')")

#print(" Ledger shell loaded. ")