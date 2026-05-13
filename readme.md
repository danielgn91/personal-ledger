# Personal Ledger

Local-first personal accounting system using double-entry bookkeeping.

The project focuses on simplicity, data ownership, analytical flexibility,
and robust accounting foundations.

---

## Philosophy

- Local-first architecture
- Open and portable data
- Double-entry accounting
- Minimal and extensible chart of accounts
- Analytics separated from accounting structure
- SQLite as single source of truth
- Power BI-friendly data model

---

## Stack

- Python
- SQLite
- SQLModel
- NiceGUI

---

## Current Goals

- Editable chart of accounts
- Double-entry transaction validation
- Analytical tagging system
- Ledger visualization and filtering
- CSV export
- Power BI integration

---

## Architecture Overview

The system is based on a traditional accounting ledger model:

- `Transaction`
  - Represents a complete accounting event

- `Entry`
  - Individual debit/credit lines inside a transaction

- `Account`
  - Chart of accounts hierarchy

- `Tag`
  - Analytical categorization layer

---

## Accounting Conventions

Positive amounts represent debits.

Negative amounts represent credits.

Every transaction must satisfy:

```math
\sum entries.amount = 0
```

Amounts are stored as signed integers in the smallest currency unit to guarantee deterministic arithmetic precision.

Example:

- $10,50 → `1050`
- $-42,99 → `-4299`

---

## Planned Features

- Account management UI
- Transaction editor
- Recurring transactions
- Dashboarding
- Native analytics
- CSV import/export
- Optional cloud sync

---

## Status

Early development / schema modeling phase.