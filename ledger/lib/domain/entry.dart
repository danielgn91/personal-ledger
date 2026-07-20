class Entry {
  final String id;

  final String transactionId;
  final String accountId;

  final int amount;
  final String? description;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Entry({
    required this.id,
    required this.transactionId,
    required this.accountId,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  bool get isDebit => amount > 0;

  bool get isCredit => amount < 0;
}