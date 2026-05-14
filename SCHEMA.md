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
Transaction
    |
    | 1:N
    v
Entry ---- N:1 ---- Account
                    |
                    | N:M
                    v
                   Tag
```

---

# Tables

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
| id | INTEGER | Primary key |
| parent_id | INTEGER nullable | Parent account reference |
| code | TEXT | Human-readable account code |
| name | TEXT | Account name |
| account_type | TEXT | asset, liability, equity, revenue, expense |
| normal_balance | TEXT | debit or credit |
| is_postable | BOOLEAN | Can receive entries directly |
| is_active | BOOLEAN | Soft activation state |

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
| id | INTEGER | Primary key |
| transaction_date | DATE | Competence/accounting date |
| description | TEXT | Human-readable description |
| created_at | DATETIME | Creation timestamp |

---

## Entry

Represents an individual ledger line.

Each entry affects exactly one account.

### Fields

| Field | Type | Description |
|---|---|---|
| id | INTEGER | Primary key |
| transaction_id | INTEGER | Parent transaction |
| account_id | INTEGER | Affected account |
| amount | INTEGER | Signed amount in cents |
| description | TEXT nullable | Optional line description |

---

## Tag

Represents an analytical categorization label.

Tags are intentionally separated from the chart of accounts structure.

### Fields

| Field | Type | Description |
|---|---|---|
| id | INTEGER | Primary key |
| name | TEXT | Unique normalized tag name |
| is_active | BOOLEAN | Soft activation state |

---

## AccountTag

Many-to-many relationship between accounts and tags.

### Fields

| Field | Type | Description |
|---|---|---|
| account_id | INTEGER | Referenced account |
| tag_id | INTEGER | Referenced tag |

Composite primary key:

```text
(account_id, tag_id)
```

---

# Design Decisions

## Integer Monetary Storage

Amounts are stored as integers instead of floating point values
to avoid rounding and precision issues.

---

## Hierarchical Accounts

The real account hierarchy is defined by `parent_id`,
not by account codes.

---

## Analytical Tags

Tags provide analytical categorization without requiring
an excessively granular chart of accounts.

---

## ORM Strategy

The current implementation intentionally avoids advanced ORM
relationships and abstractions during the MVP phase
to prioritize simplicity and transparency.

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