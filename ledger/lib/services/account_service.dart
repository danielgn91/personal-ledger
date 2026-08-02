import '../domain/account.dart';
import '../domain/enums/account_type.dart';
import '../domain/enums/normal_balance.dart';

enum AccountError {
  deleted,
  invalidName,
  invalidCode,
  alreadyInactive,
}

class AccountException implements Exception {
  final AccountError error;

  const AccountException(this.error);
}

class AccountService {
  const AccountService();

  Account create({
    required String id,
    required String ledgerId,
    required String code,
    required String name,
    required AccountType accountType,
    required NormalBalance normalBalance,
    required bool isPostable,
    required DateTime now,
    String? parentId,
  }) {
    _validateName(name);
    _validateCode(code);

    return Account(
      id: id,
      parentId: parentId,
      ledgerId: ledgerId,
      code: code,
      name: name,
      accountType: accountType,
      normalBalance: normalBalance,
      isPostable: isPostable,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  Account update({
    required Account account,
    String? name,
    String? code,
    AccountType? accountType,
    NormalBalance? normalBalance,
    bool? isPostable,
    String? parentId,
    required DateTime now,
  }) {
    _ensureActive(account);

    final newName = name ?? account.name;
    final newCode = code ?? account.code;

    _validateName(newName);
    _validateCode(newCode);

    return Account(
      id: account.id,
      parentId: parentId ?? account.parentId,
      ledgerId: account.ledgerId,
      code: newCode,
      name: newName,
      accountType: accountType ?? account.accountType,
      normalBalance: normalBalance ?? account.normalBalance,
      isPostable: isPostable ?? account.isPostable,
      isActive: account.isActive,
      createdAt: account.createdAt,
      updatedAt: now,
      deletedAt: account.deletedAt,
    );
  }

  Account deactivate({
    required Account account,
    required DateTime now,
  }) {
    _ensureActive(account);

    return Account(
      id: account.id,
      parentId: account.parentId,
      ledgerId: account.ledgerId,
      code: account.code,
      name: account.name,
      accountType: account.accountType,
      normalBalance: account.normalBalance,
      isPostable: account.isPostable,
      isActive: false,
      createdAt: account.createdAt,
      updatedAt: now,
      deletedAt: account.deletedAt,
    );
  }

  Account delete({
    required Account account,
    required DateTime now,
  }) {
    if (account.deletedAt != null) {
      throw const AccountException(
        AccountError.deleted,
      );
    }

    return Account(
      id: account.id,
      parentId: account.parentId,
      ledgerId: account.ledgerId,
      code: account.code,
      name: account.name,
      accountType: account.accountType,
      normalBalance: account.normalBalance,
      isPostable: account.isPostable,
      isActive: false,
      createdAt: account.createdAt,
      updatedAt: now,
      deletedAt: now,
    );
  }

  void _ensureActive(Account account) {
    if (account.deletedAt != null) {
      throw const AccountException(
        AccountError.deleted,
      );
    }

    if (!account.isActive) {
      throw const AccountException(
        AccountError.alreadyInactive,
      );
    }
  }

  void _validateName(String name) {
    if (name.trim().isEmpty) {
      throw const AccountException(
        AccountError.invalidName,
      );
    }
  }

  void _validateCode(String code) {
    if (code.trim().isEmpty) {
      throw const AccountException(
        AccountError.invalidCode,
      );
    }
  }
}
