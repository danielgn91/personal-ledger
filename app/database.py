from sqlmodel import SQLModel, Session, create_engine
import app.models


class LedgerDatabase:

    def __init__(self, db_path: str):
        self.db_path = db_path

        self.engine = create_engine(
            f"sqlite:///{db_path}"
        )

    def create_tables(self) -> None:
        """
        Creates all database tables registered
        in SQLModel metadata.
        """

        SQLModel.metadata.create_all(self.engine)

    def get_session(self) -> Session:
        """
        Creates and returns a database session.
        """

        return Session(self.engine)