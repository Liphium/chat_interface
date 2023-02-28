import 'package:drift/drift.dart';

class Setting extends Table {

  TextColumn get key => text()();
  TextColumn get value => text()();
}