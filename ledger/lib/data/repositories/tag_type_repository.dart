import 'package:drift/drift.dart';

import '../../domain/tag_type.dart' as domain;
import '../database/database.dart';

class TagTypeRepository {
  final AppDatabase database;

  const TagTypeRepository(this.database);

  Future<domain.TagType?> findById(String id) async {
    final row = await (database.select(database.tagTypes)
          ..where((tagType) => tagType.id.equals(id)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.TagType>> findAll() async {
    final rows = await database.select(database.tagTypes).get();

    return rows.map<domain.TagType>(_toDomain).toList();
  }

  Future<void> insert(domain.TagType tagType) async {
    await database.into(database.tagTypes).insert(
          _toCompanion(tagType),
        );
  }

  Future<void> update(domain.TagType tagType) async {
    await database
        .update(database.tagTypes)
        .replace(_toCompanion(tagType));
  }

  Future<bool> delete(String id) async {
    final deleted = await (database.delete(database.tagTypes)
          ..where((tagType) => tagType.id.equals(id)))
        .go();

    return deleted > 0;
  }

  domain.TagType _toDomain(TagType row) {
    return domain.TagType(
      id: row.id,
      ledgerId: row.ledgerId,
      name: row.name,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TagTypesCompanion _toCompanion(domain.TagType tagType) {
    return TagTypesCompanion(
      id: Value(tagType.id),
      ledgerId: Value(tagType.ledgerId),
      name: Value(tagType.name),
      isActive: Value(tagType.isActive),
      createdAt: Value(tagType.createdAt),
      updatedAt: Value(tagType.updatedAt),
      deletedAt: Value(tagType.deletedAt),
    );
  }
}