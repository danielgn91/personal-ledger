from dataclasses import dataclass

@dataclass
class Posting:
    account_id: int
    amount: int
    description: str | None = None