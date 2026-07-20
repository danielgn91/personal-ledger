import 'enums/transaction_status.dart';

class Transaction {
  final String id;
  final String ledgerId;

  final DateTime transactionDate;
  final String description;

  final TransactionStatus status;

  final DateTime createdAt;
  final DateTime? postedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Transaction({
    required this.id,
    required this.ledgerId,
    required this.transactionDate,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.postedAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  bool get isPosted => status == TransactionStatus.posted;

  bool get isPlanned => status == TransactionStatus.planned;

  bool get isCancelled => status == TransactionStatus.cancelled;

  bool get isDeleted => deletedAt != null;
}