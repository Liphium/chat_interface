
import 'package:drift/drift.dart';

class Friend extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get tag => text()();
    TextColumn get vaultId => text()();
    TextColumn get keys => text()();

    @override
    Set<Column> get primaryKey => {id};

}