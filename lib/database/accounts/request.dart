
import 'package:drift/drift.dart';

class Request extends Table {
  
    BoolColumn get self => boolean()(); // Whether the request is sent by the current user
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get tag => text()();
    TextColumn get keys => text()();

    @override
    Set<Column> get primaryKey => {id};

}