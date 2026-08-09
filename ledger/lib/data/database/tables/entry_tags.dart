import 'package:drift/drift.dart';

class EntryTags extends Table {
  TextColumn get entryId => text()();

  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {entryId, tagId};
}