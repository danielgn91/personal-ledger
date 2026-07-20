class Tag {
  final String id;
  final String ledgerId;

  final String name;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Tag({
    required this.id,
    required this.ledgerId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
}