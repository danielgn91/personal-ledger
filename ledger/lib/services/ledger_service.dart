import 'package:uuid/uuid.dart';

import '../data/database/database.dart';
import '../data/repositories/ledger_repository.dart';
import '../domain/ledger.dart' as domain;

enum LedgerError {
  invalidName,
}

class LedgerException implements Exception {
  final LedgerError error;

  const LedgerException(this.error);

  @override
  String toString() {
    return 'LedgerException: $error';
  }
}

class LedgerService {
  LedgerService(AppDatabase database)
      : _repository = LedgerRepository(database);

  final LedgerRepository _repository;
  static const Uuid _uuid = Uuid();

  Future<List<domain.Ledger>> findAll() {
    return _repository.findAll();
  }

  Future<domain.Ledger> create({
    required String name,
  }) async {
    _validateName(name);

    final now = DateTime.now();

    final ledger = domain.Ledger(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.insert(ledger);

    return ledger;
  }

  Future<domain.Ledger> update({
    required Ledger ledger,
    required String name,
  }) async {
    _validateName(name);

    final updatedLedger = domain.Ledger(
      id: ledger.id,
      name: name.trim(),
      createdAt: ledger.createdAt,
      updatedAt: DateTime.now(),
    );

    await _repository.update(updatedLedger);

    return updatedLedger;
  }

  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const LedgerException(
        LedgerError.invalidName,
      );
    }
  }
}