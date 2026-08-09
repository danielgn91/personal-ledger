import 'package:drift/drift.dart';
import '../../domain/enums/account_type.dart';
import '../../domain/enums/normal_balance.dart';
import '../../domain/account.dart' as domain;
import '../database/database.dart';

class AccountRepository {
  final AppDatabase database;

  const AccountRepository(this.database);

  Future<domain.Account?> findById(String id) async {
    final row = await (database.select(database.accounts)
          ..where((account) => account.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.Account>> findAll() async {
    final rows = await database.select(database.accounts).get();

    return rows.map<domain.Account>(_toDomain).toList();
  }

  Future<void> insert(domain.Account account) async {
    await database.into(database.accounts).insert(
          _toCompanion(account),
        );
  }

  Future<void> update(domain.Account account) async {
    await database
        .update(database.accounts)
        .replace(_toCompanion(account));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.accounts)
          ..where((account) => account.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.Account _toDomain(Account row) {
    return domain.Account(
      id: row.id,
      parentId: row.parentId,
      ledgerId: row.ledgerId,
      code: row.code,
      name: row.name,
      accountType: AccountType.values[row.accountType],
      normalBalance: NormalBalance.values[row.normalBalance],
      isPostable: row.isPostable,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  AccountsCompanion _toCompanion(domain.Account account) {
    return AccountsCompanion(
      id: Value(account.id),
      parentId: Value(account.parentId),
      ledgerId: Value(account.ledgerId),
      code: Value(account.code),
      name: Value(account.name),
      accountType: Value(account.accountType.index),
      normalBalance: Value(account.normalBalance.index),
      isPostable: Value(account.isPostable),
      isActive: Value(account.isActive),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      deletedAt: Value(account.deletedAt),
    );
  }
}