import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─── Favorites table ──────────────────────────────────────────────────────────

class Favorites extends Table {
  IntColumn get id => integer()();
  TextColumn get productJson => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Product cache table ──────────────────────────────────────────────────────

/// Stores cached product lists keyed by category slug.
/// Key "_all" is used for the uncategorised home feed.
class CachedProducts extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get productsJson => text()();
  IntColumn get total => integer()();
  DateTimeColumn get cachedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Favorites, CachedProducts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bazar_db');
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(cachedProducts);
          }
        },
      );
}
