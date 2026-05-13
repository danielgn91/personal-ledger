from decimal import Decimal

from sqlmodel import SQLModel, Field


class Entry(SQLModel, table=True):
    """
    Represents an individual ledger line inside a transaction.

    Each entry affects exactly one account.

    Positive amounts represent debits.
    Negative amounts represent credits.

    The sum of all entries belonging to the same transaction
    must always equal zero.
    """

    id: int | None = Field(
        default=None,
        primary_key=True,
        description="Unique internal ledger entry identifier."
    )

    transaction_id: int = Field(
        foreign_key="transaction.id",
        index=True,
        description="Reference to the parent transaction."
    )

    account_id: int = Field(
        foreign_key="account.id",
        index=True,
        description="Reference to the affected account."
    )

    amount: int = Field(
    description=(
            "Signed monetary amount stored in the smallest currency unit "
            "(e.g. cents). "
            "Positive values represent debits; "
            "negative values represent credits."
        )
    )

    description: str | None = Field(
        default=None,
        description=(
            "Optional line-level description "
            "for additional context."
        )
    )