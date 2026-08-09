import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/accounts.dart';
import 'tables/entries.dart';
import 'tables/entry_tags.dart';
import 'tables/ledgers.dart';
import 'tables/tag_types.dart';
import 'tables/tags.dart';
import 'tables/transactions.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Ledgers,
    Accounts,
    Transactions,
    Entries,
    Tags,
    EntryTags,
    TagTypes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(File file) : super(_openConnection(file));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(File file) {
  return LazyDatabase(() async {
    return NativeDatabase.createInBackground(file);
  });
}