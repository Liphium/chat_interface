import 'package:drift/drift.dart';

class Friend extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get vaultId => text()();
  TextColumn get keys => text()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}
