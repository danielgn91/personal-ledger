import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get id => text()();

  TextColumn get parentId => text().nullable()();

  TextColumn get ledgerId => text()();

  TextColumn get code => text()();

  TextColumn get name => text()();

  IntColumn get accountType => integer()();

  IntColumn get normalBalance => integer()();

  BoolColumn get isPostable => boolean()();

  BoolColumn get isActive => boolean()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}