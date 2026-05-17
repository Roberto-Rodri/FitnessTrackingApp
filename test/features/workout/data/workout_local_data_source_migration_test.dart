import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iron_log/core/database/database_helper.dart';
import 'package:iron_log/features/workout/data/datasources/workout_local_data_source.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';

class FakeDatabase implements Database {
  final List<String> executedQueries = [];
  final List<Map<String, dynamic>> insertedRecords = [];
  final List<Map<String, dynamic>> updatedRecords = [];
  final List<Map<String, dynamic>> deletedRecords = [];

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    insertedRecords.add({'table': table, 'values': values, 'conflictAlgorithm': conflictAlgorithm});
    return 1;
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    updatedRecords.add({'table': table, 'values': values, 'where': where, 'whereArgs': whereArgs});
    return 1;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    deletedRecords.add({'table': table, 'where': where, 'whereArgs': whereArgs});
    return 1;
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class FakeDatabaseHelper implements DatabaseHelper {
  final FakeDatabase fakeDb = FakeDatabase();

  @override
  Future<Database> get database async => fakeDb;

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FakeDatabaseHelper fakeDbHelper;
  late WorkoutLocalDataSourceImpl dataSource;

  setUp(() {
    fakeDbHelper = FakeDatabaseHelper();
    dataSource = WorkoutLocalDataSourceImpl(fakeDbHelper);
  });

  group('WorkoutLocalDataSource Migration Tests', () {
    test('saveBodyWeightLog should correctly call insert with ConflictAlgorithm.replace', () async {
      final date = DateTime(2026, 5, 17);
      final log = BodyWeightLog(
        id: 'log1',
        date: date,
        weight: 75.5,
      );

      await dataSource.saveBodyWeightLog(log);

      final inserts = fakeDbHelper.fakeDb.insertedRecords;
      expect(inserts.length, 1);
      expect(inserts.first['table'], 'body_weight_logs');
      expect(inserts.first['conflictAlgorithm'], ConflictAlgorithm.replace);
      expect(inserts.first['values'], {
        'id': 'log1',
        'timestamp': date.millisecondsSinceEpoch,
        'weight': 75.5,
      });
    });

    test('updateSessionNotes should correctly issue an update to workout_sessions', () async {
      await dataSource.updateSessionNotes(123, 'Felt strong today.');

      final updates = fakeDbHelper.fakeDb.updatedRecords;
      expect(updates.length, 1);
      expect(updates.first['table'], 'workout_sessions');
      expect(updates.first['values'], {'notes': 'Felt strong today.'});
      expect(updates.first['where'], 'id = ?');
      expect(updates.first['whereArgs'], [123]);
    });
  });
}
