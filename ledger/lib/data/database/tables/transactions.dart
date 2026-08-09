import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id => text()();

  TextColumn get ledgerId => text()();

  DateTimeColumn get transactionDate => dateTime()();

  TextColumn get description => text()();

  IntColumn get status => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get postedAt => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}