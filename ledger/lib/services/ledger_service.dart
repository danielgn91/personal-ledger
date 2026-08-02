import '../domain/ledger.dart';

enum LedgerError {
  deleted,
  invalidName,
}

class LedgerException implements Exception {
  final LedgerError error;

  const LedgerException(this.error);
}

class LedgerService {
  const LedgerService();

  Ledger create({
    required String id,
    required String name,
    required DateTime now,
  }) {
    _validateName(name);

    return Ledger(
      id: id,
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  Ledger update({
    required Ledger ledger,
    required String name,
    required DateTime now,
  }) {
    _validateName(name);

    return Ledger(
      id: ledger.id,
      name: name.trim(),
      createdAt: ledger.createdAt,
      updatedAt: now,
    );
  }

  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const LedgerException(
        LedgerError.invalidName,
      );
    }
  }
}