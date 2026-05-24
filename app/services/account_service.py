from app.database import LedgerDatabase
from app.models import Account, AccountType, NormalBalance
from sqlmodel import select, Session
from app.repositories.account_repository import get_account_by_id

class InvalidAccountError(Exception):
    pass

class InvalidParentAccountError(InvalidAccountError):
    pass

def _is_descendant_or_self(
    session: Session,
    descendant_id: int | None,
    ancestor_id: int | None,
) -> bool:

    current_id = descendant_id

    while current_id is not None:

        if current_id == ancestor_id:
            return True

        current = get_account_by_id(session, current_id)

        current_id = (
            current.parent_id
            if current is not None
            else None
        )

    return False


def validate_parent_account(
        session: Session, 
        account_id: int | None, 
        parent_id: int | None) -> None:
    if parent_id is not None:
            
            parent_account = get_account_by_id(session, parent_id)

            if parent_account is None:
                raise InvalidAccountError("Parent Account does not exist")

            if parent_account.is_postable:
                raise InvalidParentAccountError("Postable accounts cannot have child accounts.")

            if account_id is not None and _is_descendant_or_self(session, parent_id, account_id):
                raise InvalidParentAccountError("Account cannot have one of its descendants nor itself as its new parent")



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

        validate_parent_account(session, None, parent_id)

        session.add(account)
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

def change_account_parent(
        ledger_db: LedgerDatabase,
        account_id: int,
        new_parent_id: int | None,
) -> Account:
    
    with ledger_db.get_session() as session:

        account = get_account_by_id(session, account_id)

        if account is None:
            raise InvalidAccountError("Account does not exist")
        
        validate_parent_account(session, account_id, new_parent_id)
        
        account.parent_id = new_parent_id

        session.commit()
        session.refresh(account)

        return account