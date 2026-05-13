from sqlmodel import SQLModel, Field


class Account(SQLModel, table=True):
    """
    Represents a chart of accounts node.

    Accounts are organized hierarchically using `parent_id`
    and may be either:

    - structural/synthetic accounts:
      used for grouping and aggregation only

    - postable/analytic accounts:
      allowed to receive ledger entries directly

    The real hierarchy is defined by `parent_id`,
    not by the textual account code.

    Examples
    --------
    Structural account:
        5 Expenses

    Postable account:
        5.1.01 Restaurant
    """

    id: int | None = Field(
        default=None,
        primary_key=True,
        description="Unique internal identifier for the account."
    )

    parent_id: int | None = Field(
        default=None,
        foreign_key="account.id",
        description=(
            "Self-reference to the parent account. "
            "Used to build the chart of accounts hierarchy."
        )
    )

    code: str = Field(
        index=True,
        unique=True,
        description=(
            "Human-readable account code used for ordering and display. "
            "Example: '5.1.01'."
        )
    )

    name: str = Field(
        index=True,
        description="Human-readable account name."
    )

    account_type: str = Field(
        index=True,
        description=(
            "Structural account type. "
            "Expected values: "
            "'asset', 'liability', 'equity', 'revenue', 'expense'."
        )
    )

    normal_balance: str = Field(
        description=(
            "Natural balance side of the account. "
            "Expected values: 'debit' or 'credit'."
        )
    )

    is_postable: bool = Field(
        default=True,
        description=(
            "Defines whether this account can receive ledger entries directly."
        )
    )

    is_active: bool = Field(
        default=True,
        description=(
            "Defines whether the account is active and available for new usage. "
            "Inactive accounts should normally be archived instead of deleted."
        )
    )