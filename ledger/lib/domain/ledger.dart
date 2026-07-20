class Ledger {
  final String id;
  final String name;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Ledger({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
}