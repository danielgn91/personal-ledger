import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/ledgers.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Ledgers,
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
