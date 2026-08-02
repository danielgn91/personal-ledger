import '../domain/entry.dart';
import '../domain/transaction.dart';
import '../domain/enums/transaction_status.dart';

enum TransactionError {
  deleted,
  notEditable,
  minEntries,
  unbalanced,
  entryNotFound,
  entryAlreadyExists,
  wrongTransaction,
  alreadyCancelled,
}

class TransactionException implements Exception {
  final TransactionError error;

  const TransactionException(this.error);
}

class TransactionService {
  const TransactionService();

  /// Validates the accounting invariants of a transaction.
  ///
  /// A valid transaction must:
  /// - not be deleted;
  /// - contain at least two entries;
  /// - contain no deleted entries;
  /// - have entries whose amounts sum to zero.
  void validate(
    Transaction transaction,
    List<Entry> entries,
  ) {
    if (transaction.deletedAt != null) {
      throw const TransactionException(
        TransactionError.deleted,
      );
    }

    if (entries.any((entry) => entry.deletedAt != null)) {
      throw const TransactionException(
        TransactionError.deleted,
      );
    }

    if (entries.length < 2) {
      throw const TransactionException(
        TransactionError.minEntries,
      );
    }

    final total = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    if (total != 0) {
      throw const TransactionException(
        TransactionError.unbalanced,
      );
    }
  }

  /// Adds an entry to a transaction.
  ///
  /// Only planned transactions can be edited.
  List<Entry> addEntry(
    Transaction transaction,
    List<Entry> entries,
    Entry entry,
  ) {
    _ensureEditable(transaction);

    if (entry.transactionId != transaction.id) {
      throw const TransactionException(
        TransactionError.wrongTransaction,
      );
    }

    if (entries.any((existing) => existing.id == entry.id)) {
      throw const TransactionException(
        TransactionError.entryAlreadyExists,
      );
    }

    return [...entries, entry];
  }

  /// Removes an entry from a transaction.
  ///
  /// Only planned transactions can be edited.
  List<Entry> removeEntry(
    Transaction transaction,
    List<Entry> entries,
    String entryId,
  ) {
    _ensureEditable(transaction);

    final index = entries.indexWhere(
      (entry) => entry.id == entryId,
    );

    if (index == -1) {
      throw const TransactionException(
        TransactionError.entryNotFound,
      );
    }

    final result = [...entries];
    result.removeAt(index);

    return result;
  }

  /// Posts a planned transaction.
  ///
  /// Posting makes the transaction financially effective.
  Transaction post(
    Transaction transaction,
    List<Entry> entries,
  ) {
    _ensureEditable(transaction);

    validate(transaction, entries);

    final now = DateTime.now();

    return Transaction(
      id: transaction.id,
      ledgerId: transaction.ledgerId,
      transactionDate: transaction.transactionDate,
      description: transaction.description,
      status: TransactionStatus.posted,
      createdAt: transaction.createdAt,
      postedAt: now,
      updatedAt: now,
      deletedAt: transaction.deletedAt,
    );
  }

  /// Cancels a transaction.
  ///
  /// The transaction remains in the ledger for historical purposes.
  Transaction cancel(Transaction transaction) {
    if (transaction.deletedAt != null) {
      throw const TransactionException(
        TransactionError.deleted,
      );
    }

    if (transaction.status == TransactionStatus.cancelled) {
      throw const TransactionException(
        TransactionError.alreadyCancelled,
      );
    }

    final now = DateTime.now();

    return Transaction(
      id: transaction.id,
      ledgerId: transaction.ledgerId,
      transactionDate: transaction.transactionDate,
      description: transaction.description,
      status: TransactionStatus.cancelled,
      createdAt: transaction.createdAt,
      postedAt: transaction.postedAt,
      updatedAt: now,
      deletedAt: transaction.deletedAt,
    );
  }

  void _ensureEditable(Transaction transaction) {
    if (transaction.deletedAt != null) {
      throw const TransactionException(
        TransactionError.deleted,
      );
    }

    if (transaction.status != TransactionStatus.planned) {
      throw const TransactionException(
        TransactionError.notEditable,
      );
    }
  }
}

