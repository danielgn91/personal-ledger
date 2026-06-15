from sqlmodel import SQLModel, Field


class EntryTag(SQLModel, table=True):
    """
    Association table linking entries and analytical tags.

    This model enables a many-to-many relationship where:
    - one entry may have multiple tags
    - one tag may belong to multiple entries

    Examples
    --------
    Entry: Dinner with friends
    Tags:
        - food
        - social
    """

    entry_id: int = Field(
        foreign_key="entry.id",
        primary_key=True,
        description="Reference to the tagged entry."
    )

    tag_id: int = Field(
        foreign_key="tag.id",
        primary_key=True,
        description="Reference to the associated analytical tag."
    )