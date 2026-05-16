import pytest
from app.services.account_service import create_account, InvalidAccountError
from app.models.enums import AccountType, NormalBalance


def test_create_account(ledger_db):
    acc = create_account(
        ledger_db,
        code="1.1.01",
        name="Cash",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
    )

    assert acc.id is not None
    assert acc.name == "Cash"

def test_invalid_parent(ledger_db):
    with pytest.raises(InvalidAccountError, match="Parent account does not exist."):
        create_account(
            ledger_db,
            code="1.1.02",
            name="Invalid",
            account_type=AccountType.ASSET,
            normal_balance=NormalBalance.DEBIT,
            parent_id=999,
        )

def test_parent_postable(ledger_db):
    parent = create_account(
        ledger_db,
        code="1.1.01",
        name="Parent",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        is_postable=True,
    )

    with pytest.raises(InvalidAccountError, match="Postable accounts cannot have child accounts."):
        create_account(
            ledger_db,
            code="1.1.02",
            name="Child",
            account_type=AccountType.ASSET,
            normal_balance=NormalBalance.DEBIT,
            parent_id=parent.id,
        )