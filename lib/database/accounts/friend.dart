
import 'package:drift/drift.dart';

class Friend extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get key => text()();
    TextColumn get tag => text()();
  
    @override
    Set<Column> get primaryKey => {id};

}