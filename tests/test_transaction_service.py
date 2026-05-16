import pytest
from datetime import date
from app.schemas.transactions import Posting
from app.services.transaction_service import (
                create_transaction,
                UnbalancedTransactionError,
                validate_transaction_balance,
                validate_transaction_accounts,
                InvalidTransactionError
                )
from app.models.enums import TransactionStatus

def test_create_transaction_success(ledger_db, accounts):
    tx = create_transaction(
        ledger_db=ledger_db,
        transaction_date=date.today(),
        description="salary",
        entries=[
            Posting(account_id=accounts["cash"].id, amount=1000),
            Posting(account_id=accounts["revenue"].id, amount=-1000),
        ],
        status=TransactionStatus.POSTED,
    )

    assert tx.id is not None

def test_balance_invalid():
    entries = [
        Posting(account_id=1, amount=100),
        Posting(account_id=2, amount=-50),
    ]

    with pytest.raises(UnbalancedTransactionError):
        validate_transaction_balance(entries)

def test_min_entries():
    entries = [
        Posting(account_id=1, amount=100),
    ]

    with pytest.raises(InvalidTransactionError, match="Transaction must contain at least 2 entries."):
        validate_transaction_balance(entries)

def test_account_not_found(session, accounts):
    entries = [
        Posting(account_id=999, amount=100),
        Posting(account_id=accounts["cash"].id, amount=-100),
    ]

    with pytest.raises(InvalidTransactionError, ):
        validate_transaction_accounts(session, entries)

def test_account_not_postable(ledger_db, accounts):

    entries = [
        Posting(account_id=accounts["not_postable"].id, amount=100),
        Posting(account_id=accounts["revenue"].id, amount=-100),
    ]

    with ledger_db.get_session() as session:
        with pytest.raises(InvalidTransactionError, match="Transactions must have all entries in postable accounts"):
            validate_transaction_accounts(session, entries)

def test_account_not_active(ledger_db, accounts):
    entries = [
        Posting(account_id=accounts["inactive"].id, amount=100),
        Posting(account_id=accounts["revenue"].id, amount=-100),
    ]

    with ledger_db.get_session() as session:
        with pytest.raises(InvalidTransactionError, match="Transactions must have all entries in active accounts"):
            validate_transaction_accounts(session, entries)