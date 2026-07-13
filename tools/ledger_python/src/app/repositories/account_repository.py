from app.models import Account
from sqlmodel import select, Session

def get_account_by_id(session: Session, account_id: int):
    statement = select(Account).where(
            Account.id == account_id
        )
    return session.exec(statement).first()