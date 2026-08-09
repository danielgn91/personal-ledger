import 'package:drift/drift.dart';

class TagTypes extends Table {
  TextColumn get id => text()();

  TextColumn get ledgerId => text()();

  TextColumn get name => text()();

  BoolColumn get isActive => boolean()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}