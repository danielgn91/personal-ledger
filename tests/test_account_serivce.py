import pytest

from app.models.enums import AccountType, NormalBalance

from app.services.account_service import (
    create_account,
    change_account_parent,
    InvalidAccountError,
    InvalidParentAccountError,
)


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

    with pytest.raises(
        InvalidAccountError,
        match="Parent Account does not exist",
    ):

        create_account(
            ledger_db,
            code="1.1.02",
            name="Invalid",
            account_type=AccountType.ASSET,
            normal_balance=NormalBalance.DEBIT,
            parent_id=999,
        )


def test_parent_postable(accounts, ledger_db):

    parent = accounts["cash"]

    with pytest.raises(
        InvalidParentAccountError,
        match="Postable accounts cannot have child accounts",
    ):

        create_account(
            ledger_db,
            code="1.1.02",
            name="Child",
            account_type=AccountType.ASSET,
            normal_balance=NormalBalance.DEBIT,
            parent_id=parent.id,
        )


def test_change_account_parent(accounts, ledger_db):

    cash = accounts["cash"]
    liabilities_root = accounts["liabilities_root"]

    updated = change_account_parent(
        ledger_db,
        cash.id,
        liabilities_root.id,
    )

    assert updated.parent_id == liabilities_root.id


def test_change_account_parent_to_root(accounts, ledger_db):

    cash = accounts["cash"]

    updated = change_account_parent(
        ledger_db,
        cash.id,
        None,
    )

    assert updated.parent_id is None


def test_change_account_parent_to_self(accounts, ledger_db):

    assets_root = accounts["assets_root"]

    with pytest.raises(
        InvalidParentAccountError,
        match="Account cannot have one of its descendants nor itself as its new parent",
    ):

        change_account_parent(
            ledger_db,
            assets_root.id,
            assets_root.id,
        )


def test_change_account_parent_to_descendant(ledger_db):

    root = create_account(
        ledger_db,
        code="10",
        name="Root",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        is_postable=False,
    )

    child = create_account(
        ledger_db,
        code="10.1",
        name="Child",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        parent_id=root.id,
        is_postable=False,
    )

    with pytest.raises(
        InvalidParentAccountError,
        match="Account cannot have one of its descendants nor itself as its new parent",
    ):

        change_account_parent(
            ledger_db,
            root.id,
            child.id,
        )


def test_change_account_parent_to_nested_descendant(ledger_db):

    root = create_account(
        ledger_db,
        code="20",
        name="Root",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        is_postable=False,
    )

    child = create_account(
        ledger_db,
        code="20.1",
        name="Child",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        parent_id=root.id,
        is_postable=False,
    )

    grandchild = create_account(
        ledger_db,
        code="20.1.1",
        name="Grandchild",
        account_type=AccountType.ASSET,
        normal_balance=NormalBalance.DEBIT,
        parent_id=child.id,
        is_postable=False
    )

    with pytest.raises(
        InvalidParentAccountError,
        match="Account cannot have one of its descendants nor itself as its new parent",
    ):

        change_account_parent(
            ledger_db,
            root.id,
            grandchild.id,
        )