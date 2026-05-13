from sqlmodel import SQLModel, Field


class AccountTag(SQLModel, table=True):
    """
    Association table linking accounts and analytical tags.

    This model enables a many-to-many relationship where:
    - one account may have multiple tags
    - one tag may belong to multiple accounts

    Examples
    --------
    Account: Restaurant
    Tags:
        - food
        - social
    """

    account_id: int = Field(
        foreign_key="account.id",
        primary_key=True,
        description="Reference to the tagged account."
    )

    tag_id: int = Field(
        foreign_key="tag.id",
        primary_key=True,
        description="Reference to the associated analytical tag."
    )