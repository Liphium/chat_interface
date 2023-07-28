
import 'package:drift/drift.dart';

class Friend extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get tag => text()();
    TextColumn get publicKey => text()();
    TextColumn get friendKey => text()();

    @override
    Set<Column> get primaryKey => {id};

}