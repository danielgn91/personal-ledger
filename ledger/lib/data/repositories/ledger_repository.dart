import 'package:drift/drift.dart';

import '../../domain/ledger.dart' as domain;
import '../database/database.dart';

class LedgerRepository {
  final AppDatabase database;

  const LedgerRepository(this.database);

  Future<domain.Ledger?> findById(String id) async {
    final row = await (database.select(database.ledgers)
          ..where((ledger) => ledger.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.Ledger>> findAll() async {
    final rows = await database.select(database.ledgers).get();

    return rows.map(_toDomain).toList();
  }

  Future<void> insert(domain.Ledger ledger) async {
    await database.into(database.ledgers).insert(
          _toCompanion(ledger),
        );
  }

  Future<void> update(domain.Ledger ledger) async {
    await database
        .update(database.ledgers)
        .replace(_toCompanion(ledger));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.ledgers)
          ..where((ledger) => ledger.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.Ledger _toDomain(Ledger row) {
    return domain.Ledger(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  LedgersCompanion _toCompanion(domain.Ledger ledger) {
    return LedgersCompanion(
      id: Value(ledger.id),
      name: Value(ledger.name),
      createdAt: Value(ledger.createdAt),
      updatedAt: Value(ledger.updatedAt),
    );
  }
}