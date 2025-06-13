import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'drift.g.dart';

class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Wallets])
class AppDatabase extends _$AppDatabase {
  AppDatabase([final QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'cupcake_db',
    );
  }
}
