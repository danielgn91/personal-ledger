import 'enums/account_type.dart';
import 'enums/normal_balance.dart';

class Account {
  final String id;
  final String? parentId;
  final String ledgerId;

  final String code;
  final String name;

  final AccountType accountType;
  final NormalBalance normalBalance;

  final bool isPostable;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Account({
    required this.id,
    required this.parentId,
    required this.ledgerId,
    required this.code,
    required this.name,
    required this.accountType,
    required this.normalBalance,
    required this.isPostable,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}