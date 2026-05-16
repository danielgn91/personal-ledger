from datetime import date, datetime, timezone
from sqlmodel import SQLModel, Field
from app.models.enums import TransactionStatus

class Transaction(SQLModel, table=True):
    """
    Represents a complete accounting event.

    A transaction groups one or more ledger entries and must
    always satisfy the double-entry accounting rule:

        sum(entries.amount) == 0

    Examples
    --------
    Salary payment:
        Debit  Checking Account
        Credit Salary Revenue

    Credit card purchase:
        Debit  Restaurant Expense
        Credit Credit Card Liability
    """

    id: int | None = Field(
        default=None,
        primary_key=True,
        description="Unique internal transaction identifier."
    )

    transaction_date: date = Field(
        index=True,
        description=(
            "Accounting competence date of the transaction."
        )
    )

    description: str = Field(
        index=True,
        description="Human-readable transaction description."
    )

    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        description="Timestamp indicating when the transaction was created."
    )

    status: TransactionStatus = Field(
        default=TransactionStatus.POSTED
    )