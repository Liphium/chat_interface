
import 'package:drift/drift.dart';

class Request extends Table {
  
    TextColumn get id => text()();
    TextColumn get name => text()();
    TextColumn get tag => text()();
    BoolColumn get self => boolean()(); // Whether the request is sent by the current user
    TextColumn get vaultId => text()();
    TextColumn get storedActionId => text()();
    TextColumn get keys => text()();

    @override
    Set<Column> get primaryKey => {id};

}