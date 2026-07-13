import csv
from sqlmodel import Session

from app.database import LedgerDatabase
from app.services.account_service import create_account
from app.models.enums import AccountType, NormalBalance


class ImportError(Exception):
    pass


def import_chart_of_accounts_csv(session: Session, file_path: str):
    """
    Imports a chart of accounts from a CSV file.

    Expected columns:
    - code
    - name
    - account_type
    - normal_balance
    - parent_code (optional)
    - is_postable (optional)
    """

    with open(file_path, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    # code -> created account
    created = {}

    # rows still not processed
    pending = rows.copy()

    iteration = 0
    max_iterations = len(rows) * 2  # safety guard

    while pending:
        iteration += 1

        if iteration > max_iterations:
            raise ImportError("Possible circular dependency in chart of accounts")

        progress = False

        for row in pending[:]:
            code = row["code"]
            parent_code = row.get("parent_code") or None

            # parent must either not exist or already be created
            if parent_code is not None and parent_code not in created:
                continue

            parent_id = created[parent_code].id if parent_code else None

            account = create_account(
                session=session,
                code=code,
                name=row["name"],
                account_type=AccountType[row["account_type"]],
                normal_balance=NormalBalance[row["normal_balance"]],
                parent_id=parent_id,
                is_postable=row.get("is_postable", "true").lower() == "true",
            )

            created[code] = account
            pending.remove(row)
            progress = True

        if not progress:
            orphan_codes = [r["code"] for r in pending]
            raise ImportError(
                f"Orphan accounts detected (missing parents or invalid references): {orphan_codes}"
            )

    return created

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 3:
        print("Usage: python import_chart_of_accounts.py <db_path> <csv_file>")
        sys.exit(1)

    db_path = sys.argv[1]
    csv_path = sys.argv[2]

    ledger_db = LedgerDatabase(db_path)

    with ledger_db.get_session() as session:
        with session.begin():
            result = import_chart_of_accounts_csv(session, csv_path)

    print(f"Imported {len(result)} accounts successfully.")