import pytest
from sqlmodel import SQLModel, Session, create_engine

from app.database import LedgerDatabase
from app.services.account_service import create_account
from app.models.enums import AccountType, NormalBalance


# -------------------------
# ENGINE / DB
# -------------------------

@pytest.fixture
def engine():
    engine = create_engine("sqlite:///:memory:", echo=False)
    SQLModel.metadata.create_all(engine)
    return engine


@pytest.fixture
def session(engine):
    with Session(engine) as session:
        yield session


@pytest.fixture
def ledger_db(engine):
    class TestLedgerDB(LedgerDatabase):
        def __init__(self):
            self.engine = engine

        def get_session(self):
            return Session(self.engine)

    return TestLedgerDB()


# -------------------------
# ACCOUNTS FIXTURES
# -------------------------

@pytest.fixture
def accounts(ledger_db):
    """
    Creates a minimal chart of accounts for testing.
    """

    cash = create_account(
        ledger_db,
        code="1.1.01",
        name="Cash",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
    )

    revenue = create_account(
        ledger_db,
        code="4.1.01",
        name="Revenue",
        account_type=AccountType.REVENUE,
        normal_balance=NormalBalance.CREDIT,
    )

    expense = create_account(
        ledger_db,
        code="5.1.01",
        name="Expense",
        account_type=AccountType.EXPENSE,
        normal_balance=NormalBalance.DEBIT,
    )

    not_postable = create_account(
        ledger_db,
        code = "3.3.01",
        name="analitical",
        account_type=AccountType.EQUITY,
        normal_balance=NormalBalance.CREDIT,
        is_postable=False
    )

    inactive = create_account(
        ledger_db,
        code = "2.3.01",
        name="analitical",
        account_type=AccountType.LIABILITY,
        normal_balance=NormalBalance.CREDIT,
        is_active=False
    )

    return {
        "cash": cash,
        "revenue": revenue,
        "expense": expense,
        "not_postable": not_postable,
        "inactive": inactive
    }