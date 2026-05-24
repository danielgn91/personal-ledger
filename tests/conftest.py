import pytest
from sqlmodel import SQLModel, create_engine, Session

from app.database import LedgerDatabase
from app.services.account_service import create_account
from app.models.enums import AccountType, NormalBalance


# -------------------------
# ENGINE / DB
# -------------------------

@pytest.fixture
def engine():
    engine = create_engine(
        "sqlite:///:memory:",
        echo=False,
    )

    SQLModel.metadata.create_all(engine)

    return engine


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

    assets_root = create_account(
        ledger_db,
        code="1",
        name="Assets",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        is_postable=False,
    )

    liabilities_root = create_account(
        ledger_db,
        code="2",
        name="Liabilities",
        account_type=AccountType.LIABILITY,
        normal_balance=NormalBalance.CREDIT,
        is_postable=False,
    )

    revenue_root = create_account(
        ledger_db,
        code="4",
        name="Revenue",
        account_type=AccountType.REVENUE,
        normal_balance=NormalBalance.CREDIT,
        is_postable=False,
    )

    expense_root = create_account(
        ledger_db,
        code="5",
        name="Expenses",
        account_type=AccountType.EXPENSE,
        normal_balance=NormalBalance.DEBIT,
        is_postable=False,
    )

    cash = create_account(
        ledger_db,
        code="1.1.01",
        name="Cash",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        parent_id=assets_root.id,
    )

    revenue = create_account(
        ledger_db,
        code="4.1.01",
        name="Revenue",
        account_type=AccountType.REVENUE,
        normal_balance=NormalBalance.CREDIT,
        parent_id=revenue_root.id,
    )

    expense = create_account(
        ledger_db,
        code="5.1.01",
        name="Expense",
        account_type=AccountType.EXPENSE,
        normal_balance=NormalBalance.DEBIT,
        parent_id=expense_root.id,
    )

    non_postable = create_account(
        ledger_db,
        code="3.3.01",
        name="Non-postable",
        account_type=AccountType.EQUITY,
        normal_balance=NormalBalance.CREDIT,
        is_postable=False,
    )

    inactive = create_account(
        ledger_db,
        code="2.3.01",
        name="Inactive Liability",
        account_type=AccountType.LIABILITY,
        normal_balance=NormalBalance.CREDIT,
        parent_id=liabilities_root.id,
        is_active=False,
    )

    return {
        "assets_root": assets_root,
        "liabilities_root": liabilities_root,
        "revenue_root": revenue_root,
        "expense_root": expense_root,
        "cash": cash,
        "revenue": revenue,
        "expense": expense,
        "non_postable": non_postable,
        "inactive": inactive,
    }