# Schema Documentation

This document describes the current database schema and accounting conventions
used by the Personal Ledger project.

---

# Core Principles

- Double-entry bookkeeping
- Local-first architecture
- SQLite as source of truth
- Analytical flexibility
- Append-oriented ledger mindset

---

# Accounting Rules

Positive amounts represent debits.

Negative amounts represent credits.

Every transaction must satisfy:

```math
\sum entries.amount = 0
```

Amounts are stored as signed integers in the smallest currency unit.

Examples:

| Value | Stored |
|---|---|
| $10,50 | 1050 |
| $-42,99 | -4299 |

---

# Entity Overview

```text
Ledger
 |
 +-- Account
 |
 +-- Transaction
 |       |
 |       +-- Entry
 |
 +-- Tag

Entry <----> Tag
```

---

# Tables


---

## Ledger

Represents a set of financial data

### Fields

| Field | Type | Description |
|---|---|---|
| id | TEXT | Primary key |
| name | TEXT | Ledger name |
| created_at | DATETIME | creation timestamp |
| updated_at |DATETIME| last update timestamp|

---

## Account

Represents a chart of accounts node.

Accounts may be:
- structural/synthetic
- postable/analytic

Hierarchy is defined using `parent_id`.

### Fields

| Field | Type | Description |
|---|---|---|
| id | TEXT | Primary key |
| parent_id | TEXT nullable | Parent account reference |
| ledger_id | TEXT | Owning ledger |
| code | TEXT | Human-readable account code |
| name | TEXT | Account name |
| account_type | TEXT | asset, liability, equity, revenue, expense |
| normal_balance | TEXT | debit or credit |
| is_postable | BOOLEAN | Can receive entries directly |
| is_active | BOOLEAN | Soft activation state |
| created_at | DATETIME | creation timestamp |
| updated_at | DATETIME | last update timestamp |
| deleted_at | DATETIME nullable | deletion timestamp|

---

## Transaction

Represents a complete accounting event.

Examples:
- salary payment
- credit card purchase
- rent payment

### Fields

| Field | Type | Description |
|---|---|---|
| id | TEXT | Primary key |
| ledger_id | TEXT | Owning ledger |
| transaction_date | DATE | Competence/accounting date |
| description | TEXT | Human-readable description |
| status | TEXT | planned, posted, cancelled |
| created_at | DATETIME | Creation timestamp |
| posted_at | DATETIME | Posting timestamp |
| updated_at | DATETIME | last update timestamp |
| deleted_at | DATETIME nullable | deletion timestamp |

---
Transactions have a lifecycle status:

- `planned`
  - Expected or scheduled transaction.
  - Does not affect real balances.

- `posted`
  - Confirmed transaction.
  - Affects balances and financial reports.

- `cancelled`
  - Invalidated or abandoned transaction.
  - Preserved for historical/audit purposes.

## Entry

Represents an individual ledger line.

Each entry affects exactly one account.

### Fields

| Field | Type | Description |
|---|---|---|
| id | TEXT | Primary key |
| transaction_id | TEXT | Parent transaction |
| account_id | TEXT | Affected account |
| amount | INTEGER | Signed amount in cents |
| description | TEXT nullable | Optional line description |
|created_at | DATETIME | creation timestamp |
| updated_at | DATETIME | last update timestamp |
| deleted_at | DATETIME nullable | deletion timestamp |

---

## Tag

Represents an analytical categorization label.

Tags are intentionally separated from the chart of accounts structure.

### Fields

| Field | Type | Description |
|---|---|---|
| id | TEXT | Primary key |
| ledger_id | TEXT | Owning ledger |
| name | TEXT | normalized tag name |
| is_active | BOOLEAN | Soft activation state |
| created_at | DATETIME | creation timestamp |
| updated_at | DATETIME | last update timestamp |
| deleted_at | DATETIME nullable | deletion timestamp |

Unique(ledger_id, name)

---

## EntryTag

Many-to-many relationship between Entries and tags.

### Fields

| Field | Type | Description |
|---|---|---|
| entry_id | TEXT | Referenced entry |
| tag_id | TEXT | Referenced tag |

Composite primary key:

```text
(entry_id, tag_id)
```

---

# Design Decisions

## Ledger Ownership

Accounts, Transactions and Tags belong to exactly one Ledger.

Entries belong indirectly through their Transaction.


## Integer Monetary Storage

Amounts are stored as integers instead of floating point values
to avoid rounding and precision issues.

---

## Hierarchical Accounts

The real account hierarchy is defined by `parent_id`,
not by account codes.

---

## Transaction Lifecycle

Transactions may exist before becoming financially effective.

Only transactions with status `posted`
affect real balances and accounting reports.

---

## Entry Lifecycle

Entries are mutable while transactions are being edited.

Posted transaction entries should not be deleted.
Corrections should be performed by cancelling or reversing transactions.



## Analytical Tags

Tags provide analytical categorization without requiring
an excessively granular chart of accounts.

---

# Future Possibilities

Potential future extensions include:

- Entry-level tags
- Recurring transactions
- Attachments/documents
- Multi-currency support
- Native dashboards
- Sync layer
- Audit/event system