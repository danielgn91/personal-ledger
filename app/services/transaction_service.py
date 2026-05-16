from datetime import date
from app.database import LedgerDatabase
from sqlmodel import Session
from app.models import Transaction, TransactionStatus, Entry
from app.repositories.account_repository import get_account_by_id
from app.schemas.transactions import Posting

class UnbalancedTransactionError(Exception):
    """Raised when transaction entries do not sum to zero."""


class InvalidTransactionError(Exception):
    """Raised when a transaction violates ledger rules."""

def validate_transaction_balance(entries: list[Posting]) -> None:
    """
    Validate transaction entries.

    Rules:
    - transaction must contain at least 2 entries
    - total amount must equal zero
    """

    if len(entries) < 2:
        raise InvalidTransactionError(
            "Transaction must contain at least 2 entries."
        )

    if sum(entry.amount for entry in entries) != 0:
        raise UnbalancedTransactionError(
            "Transaction entries must sum to zero."
        )

        
def validate_transaction_accounts(
    session: Session,
    entries: list[Posting],
) -> None:
    for entry in entries:
        entry_account = get_account_by_id(session,entry.account_id)
        if entry_account is None: raise InvalidTransactionError(
            "Transactions must have all entries in existing accounts"
        )
        if not entry_account.is_postable: raise InvalidTransactionError(
            "Transactions must have all entries in postable accounts"
        )
        if not entry_account.is_active: raise InvalidTransactionError(
            "Transactions must have all entries in active accounts"
        )
        

def create_transaction(
    ledger_db: LedgerDatabase,
    transaction_date: date,
    description: str,
    entries: list[Posting],
    status: TransactionStatus = TransactionStatus.POSTED,
) -> Transaction:
    """
    Create and persist a balanced ledger transaction.

    Parameters
    ----------
    transaction_date : date
        Accounting/competence date.

    description : str
        Human-readable transaction description.

    entries : list[Posting]
        List of entry payloads.

    status : TransactionStatus
        Transaction lifecycle status.

    Returns
    -------
    Transaction
        Persisted transaction object.
    """

    #entries = [entry for entry in entries if entry.amount != 0]

    validate_transaction_balance(entries)
    


    with ledger_db.get_session() as session:

        validate_transaction_accounts(session, entries)

        transaction = Transaction(
            transaction_date=transaction_date,
            description=description,
            status=status,
        )

        session.add(transaction)

        # Generates transaction.id before commit
        session.flush()

        for entry_data in entries:

            entry = Entry(
                transaction_id=transaction.id,
                account_id=entry_data.account_id,
                amount=entry_data.amount,
                description=entry_data.description,
            )

            session.add(entry)

        session.commit()

        session.refresh(transaction)

        return transaction
