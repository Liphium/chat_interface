
import 'package:drift/drift.dart';

class Friend extends Table {
  
    IntColumn get id => integer()();
    TextColumn get name => text()();
    TextColumn get tag => text()();
  
    @override
    Set<Column> get primaryKey => {id};

}