import 'package:drift/drift.dart';

import '../../domain/tag.dart' as domain;
import '../database/database.dart';

class TagRepository {
  final AppDatabase database;

  const TagRepository(this.database);

  Future<domain.Tag?> findById(String id) async {
    final row = await (database.select(database.tags)
          ..where((tag) => tag.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.Tag>> findAll() async {
    final rows = await database.select(database.tags).get();

    return rows.map<domain.Tag>(_toDomain).toList();
  }

  Future<void> insert(domain.Tag tag) async {
    await database.into(database.tags).insert(
          _toCompanion(tag),
        );
  }

  Future<void> update(domain.Tag tag) async {
    await database
        .update(database.tags)
        .replace(_toCompanion(tag));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.tags)
          ..where((tag) => tag.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.Tag _toDomain(Tag row) {
    return domain.Tag(
      id: row.id,
      ledgerId: row.ledgerId,
      tagTypeId: row.tagTypeId,
      name: row.name,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TagsCompanion _toCompanion(domain.Tag tag) {
    return TagsCompanion(
      id: Value(tag.id),
      ledgerId: Value(tag.ledgerId),
      tagTypeId: Value(tag.tagTypeId),
      name: Value(tag.name),
      isActive: Value(tag.isActive),
      createdAt: Value(tag.createdAt),
      updatedAt: Value(tag.updatedAt),
      deletedAt: Value(tag.deletedAt),
    );
  }
}