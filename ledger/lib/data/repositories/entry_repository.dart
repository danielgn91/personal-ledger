import 'package:drift/drift.dart';

import '../../domain/entry.dart' as domain;
import '../database/database.dart';

class EntryRepository {
  final AppDatabase database;

  const EntryRepository(this.database);

  Future<domain.Entry?> findById(String id) async {
    final row = await (database.select(database.entries)
          ..where((entry) => entry.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.Entry>> findAll() async {
    final rows = await database.select(database.entries).get();

    return rows.map<domain.Entry>(_toDomain).toList();
  }

  Future<void> insert(domain.Entry entry) async {
    await database.into(database.entries).insert(
          _toCompanion(entry),
        );
  }

  Future<void> update(domain.Entry entry) async {
    await database
        .update(database.entries)
        .replace(_toCompanion(entry));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.entries)
          ..where((entry) => entry.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.Entry _toDomain(Entry row) {
    return domain.Entry(
      id: row.id,
      transactionId: row.transactionId,
      accountId: row.accountId,
      amount: row.amount,
      description: row.description,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  EntriesCompanion _toCompanion(domain.Entry entry) {
    return EntriesCompanion(
      id: Value(entry.id),
      transactionId: Value(entry.transactionId),
      accountId: Value(entry.accountId),
      amount: Value(entry.amount),
      description: Value(entry.description),
      createdAt: Value(entry.createdAt),
      updatedAt: Value(entry.updatedAt),
      deletedAt: Value(entry.deletedAt),
    );
  }
}