import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iron_log/core/database/database_helper.dart';
import 'package:iron_log/features/workout/data/datasources/workout_local_data_source.dart';

class FakeDatabase implements Database {
  final List<String> executedQueries = [];
  final List<Map<String, dynamic>> insertedRecords = [];
  final List<Map<String, dynamic>> updatedRecords = [];

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    insertedRecords.add({'table': table, 'values': values});
    return 1;
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    updatedRecords.add({'table': table, 'values': values, 'where': where, 'whereArgs': whereArgs});
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    return [
      {
        'id': 1,
        'startTimestamp': 1600000000,
        'endTimestamp': 1600003600,
        'routineId': 10,
        'routineNameSnapshot': 'My Routine',
        'notes': 'Great workout',
        'totalSets': 5,
        'totalVolume': 500.0,
      }
    ];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDatabaseHelper implements DatabaseHelper {
  final FakeDatabase fakeDb = FakeDatabase();

  @override
  Future<Database> get database async => fakeDb;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeDatabaseHelper dbHelper;
  late WorkoutLocalDataSourceImpl dataSource;

  setUp(() {
    dbHelper = FakeDatabaseHelper();
    dataSource = WorkoutLocalDataSourceImpl(dbHelper);
  });

  test('startSession inserts session and updateSessionNotes updates notes', () async {
    await dataSource.startSession(10, 'My Routine');
    expect(dbHelper.fakeDb.insertedRecords.length, 1);
    expect(dbHelper.fakeDb.insertedRecords.first['table'], 'workout_sessions');
    
    await dataSource.updateSessionNotes(1, 'Great workout');
    expect(dbHelper.fakeDb.updatedRecords.length, 1);
    expect(dbHelper.fakeDb.updatedRecords.first['table'], 'workout_sessions');
    expect(dbHelper.fakeDb.updatedRecords.first['values']['notes'], 'Great workout');
  });

  test('getCompletedSessions returns sessions with notes', () async {
    final sessions = await dataSource.getCompletedSessions();
    expect(sessions.length, 1);
    expect(sessions.first.session.id, 1);
    expect(sessions.first.session.notes, 'Great workout');
  });
}
