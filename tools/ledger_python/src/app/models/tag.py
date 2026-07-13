from sqlmodel import SQLModel, Field


class Tag(SQLModel, table=True):
    """
    Represents an analytical tag used for categorization
    and reporting purposes.

    Tags are intentionally separated from the chart of accounts
    structure and are used to support flexible analytics,
    filtering, and dashboarding.

    Examples
    --------
    transportation
    food
    social
    work
    travel
    """

    id: int | None = Field(
        default=None,
        primary_key=True,
        description="Unique internal tag identifier."
    )

    name: str = Field(
        unique=True,
        index=True,
        description=(
            "Normalized tag name used for analytical grouping "
            "and filtering."
        )
    )

    is_active: bool = Field(
        default=True,
        description=(
            "Defines whether the tag is active and available "
            "for new associations."
        )
    )