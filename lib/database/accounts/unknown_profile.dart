import 'package:drift/drift.dart';

class UnknownProfile extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tag => text()();
  TextColumn get keys => text()();

  @override
  Set<Column> get primaryKey => {id};
}
