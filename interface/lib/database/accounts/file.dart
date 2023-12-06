
import 'package:drift/drift.dart';

class CloudFile extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get path => text()();
    TextColumn get key => text()();

    @override
    Set<Column> get primaryKey => {id};

}