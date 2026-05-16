from app.database import LedgerDatabase
from app.models import Account, AccountType, NormalBalance
from sqlmodel import select, Session
from app.repositories.account_repository import get_account_by_id

class InvalidAccountError(Exception):
    pass

def create_account(
    ledger_db: LedgerDatabase,
    code: str,
    name: str,
    account_type: AccountType,
    normal_balance: NormalBalance,
    parent_id: int | None = None,
    is_postable: bool = True,
    is_active: bool = True,
) -> Account:
    """
    Create and persist an account.
    """

    with ledger_db.get_session() as session:

        account = Account(
            code=code,
            name=name,
            account_type=account_type,
            normal_balance=normal_balance,
            parent_id=parent_id,
            is_postable=is_postable,
            is_active=is_active,
        )


        if parent_id is not None:
            parent = get_account_by_id(session, parent_id)

            if parent is None:
                raise InvalidAccountError(
                    "Parent account does not exist."
                )

            if parent.is_postable:
                raise InvalidAccountError(
                    "Postable accounts cannot have child accounts."
                )


        session.add(account)

        session.flush()
        session.commit()

        session.refresh(account)

        return account


def get_account(
    ledger_db: LedgerDatabase,
    account_id: int,
) -> Account | None:
    """
    Return an account by ID.
    """

    with ledger_db.get_session() as session:
        return get_account_by_id(session, account_id)