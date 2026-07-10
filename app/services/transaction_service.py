from datetime import date, datetime, timezone
from sqlmodel import Session, select
from app.models import Transaction, TransactionStatus, Entry, Account
from app.schemas.transactions import Posting
from collections.abc import Iterable, Sequence

class UnbalancedTransactionError(Exception):
    """Raised when transaction entries do not sum to zero."""

class InvalidTransactionError(Exception):
    """Raised when a transaction violates ledger rules."""

def get_transaction_entries(
    session: Session,
    transaction_id: int,
) -> list[Entry]:
    return session.exec(
        select(Entry).where(
            Entry.transaction_id == transaction_id
        )
    ).all()


def validate_transaction_balance(entries: Sequence[Posting | Entry]) -> None:
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
    entries: Iterable[Posting | Entry],
) -> None:
    for entry in entries:
        entry_account = session.get(Account, entry.account_id)
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
    session: Session,
    transaction_date: date,
    description: str,
    entries: Sequence[Posting],
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

    Returns
    -------
    Transaction
        Persisted transaction object.
    """

    #entries = [entry for entry in entries if entry.amount != 0]

    validate_transaction_balance(entries)

    validate_transaction_accounts(session, entries)

    transaction = Transaction(
        transaction_date=transaction_date,
        description=description,
        status=TransactionStatus.PLANNED,
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

    #session.commit()

    #session.refresh(transaction)

    return transaction

def edit_transaction(
        session: Session,
        transaction_id: int,
        transaction_date: date | None = None,
        description: str | None = None,
        entries: list[Posting] | None = None,
) -> Transaction:
    
    transaction = session.get(Transaction, transaction_id)

    if transaction is None:
        raise InvalidTransactionError("Transaction does not exist.")


    if transaction.status != TransactionStatus.PLANNED:
        raise InvalidTransactionError("Only planned transactions can be edited")
    
    if entries is not None:
        validate_transaction_balance(entries)
        validate_transaction_accounts(session, entries)

    if transaction_date is not None:
        transaction.transaction_date = transaction_date
    
    if description is not None:
        transaction.description = description

    if entries is not None:
        old_entries = get_transaction_entries(session, transaction_id)
        for entry in old_entries:
            session.delete(entry)

        for entry_data in entries:

            entry = Entry(
                transaction_id=transaction.id,
                account_id=entry_data.account_id,
                amount=entry_data.amount,
                description=entry_data.description,
            )

            session.add(entry)
    
    return transaction


def post_transaction(
        session: Session,
        transaction_id: int,
) -> Transaction:
    transaction = session.get(Transaction, transaction_id)
    
    if transaction is None:
        raise InvalidTransactionError("Transaction does not exist.")

    if transaction.status != TransactionStatus.PLANNED:
        raise InvalidTransactionError("Only planned transactions can be posted")
    
    entries = get_transaction_entries(session, transaction_id)

    validate_transaction_balance(entries)
    validate_transaction_accounts(session, entries)

    transaction.status = TransactionStatus.POSTED
    transaction.posted_at = datetime.now(timezone.utc)

    return transaction