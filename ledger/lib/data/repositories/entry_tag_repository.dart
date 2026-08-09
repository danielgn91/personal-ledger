import 'package:drift/drift.dart';

import '../../domain/entry_tag.dart' as domain;
import '../database/database.dart';

class EntryTagRepository {
  final AppDatabase database;

  const EntryTagRepository(this.database);

  Future<domain.EntryTag?> findById({
    required String entryId,
    required String tagId,
  }) async {
    final row = await (database.select(database.entryTags)
          ..where(
            (entryTag) =>
                entryTag.entryId.equals(entryId) &
                entryTag.tagId.equals(tagId),
          ))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<domain.EntryTag>> findAll() async {
    final rows = await database.select(database.entryTags).get();

    return rows.map<domain.EntryTag>(_toDomain).toList();
  }

  Future<void> insert(domain.EntryTag entryTag) async {
    await database.into(database.entryTags).insert(
          _toCompanion(entryTag),
        );
  }

  Future<bool> delete({
    required String entryId,
    required String tagId,
  }) async {
    final deleted = await (database.delete(database.entryTags)
          ..where(
            (entryTag) =>
                entryTag.entryId.equals(entryId) &
                entryTag.tagId.equals(tagId),
          ))
        .go();

    return deleted > 0;
  }

  domain.EntryTag _toDomain(EntryTag row) {
    return domain.EntryTag(
      entryId: row.entryId,
      tagId: row.tagId,
    );
  }

  EntryTagsCompanion _toCompanion(domain.EntryTag entryTag) {
    return EntryTagsCompanion(
      entryId: Value(entryTag.entryId),
      tagId: Value(entryTag.tagId),
    );
  }
}