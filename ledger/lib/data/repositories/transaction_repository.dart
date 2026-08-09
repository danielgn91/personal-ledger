import 'package:drift/drift.dart';

import '../../domain/enums/transaction_status.dart';
import '../../domain/transaction.dart' as domain;
import '../database/database.dart';

class TransactionRepository {
  final AppDatabase database;

  const TransactionRepository(this.database);

  Future<domain.Transaction?> findById(String id) async {
    final row = await (database.select(database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.Transaction>> findAll() async {
    final rows = await database.select(database.transactions).get();

    return rows.map<domain.Transaction>(_toDomain).toList();
  }

  Future<void> insert(domain.Transaction transaction) async {
    await database.into(database.transactions).insert(
          _toCompanion(transaction),
        );
  }

  Future<void> update(domain.Transaction transaction) async {
    await database
        .update(database.transactions)
        .replace(_toCompanion(transaction));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.transactions)
          ..where((transaction) => transaction.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.Transaction _toDomain(Transaction row) {
    return domain.Transaction(
      id: row.id,
      ledgerId: row.ledgerId,
      transactionDate: row.transactionDate,
      description: row.description,
      status: TransactionStatus.values[row.status],
      createdAt: row.createdAt,
      postedAt: row.postedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TransactionsCompanion _toCompanion(
    domain.Transaction transaction,
  ) {
    return TransactionsCompanion(
      id: Value(transaction.id),
      ledgerId: Value(transaction.ledgerId),
      transactionDate: Value(transaction.transactionDate),
      description: Value(transaction.description),
      status: Value(transaction.status.index),
      createdAt: Value(transaction.createdAt),
      postedAt: Value(transaction.postedAt),
      updatedAt: Value(transaction.updatedAt),
      deletedAt: Value(transaction.deletedAt),
    );
  }
}