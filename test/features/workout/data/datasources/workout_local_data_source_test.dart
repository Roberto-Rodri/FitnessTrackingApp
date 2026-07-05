import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iron_log/core/database/database_helper.dart';
import 'package:iron_log/features/workout/data/datasources/workout_local_data_source.dart';
import 'package:iron_log/features/workout/domain/entities/workout_set.dart';

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
  Future<List<Map<String, Object?>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    if (table == 'workout_sessions' && where != null && where.contains('routineId = ?')) {
      return [
        {
          'id': 2,
          'startTimestamp': 1600000000,
          'endTimestamp': 1600003600,
          'routineId': whereArgs![0],
          'routineNameSnapshot': 'My Routine',
          'notes': 'Previous notes',
        }
      ];
    }
    return [];
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

  test('logSet persists isWarmup flag correctly', () async {
    const normalSet = WorkoutSet(
      sessionId: 1,
      exerciseId: 10,
      weight: 100,
      reps: 10,
      isWarmup: false,
    );
    await dataSource.logSet(normalSet);
    expect(dbHelper.fakeDb.insertedRecords.last['table'], 'workout_sets');
    expect(dbHelper.fakeDb.insertedRecords.last['values']['isWarmup'], 0);

    const warmupSet = WorkoutSet(
      sessionId: 1,
      exerciseId: 10,
      weight: 50,
      reps: 15,
      isWarmup: true,
    );
    await dataSource.logSet(warmupSet);
    expect(dbHelper.fakeDb.insertedRecords.last['table'], 'workout_sets');
    expect(dbHelper.fakeDb.insertedRecords.last['values']['isWarmup'], 1);
  });

  test('getPreviousSession returns correct session excluding current one', () async {
    final session = await dataSource.getPreviousSession(10, 5);
    expect(session, isNotNull);
    expect(session!.id, 2);
    expect(session.routineId, 10);
    expect(session.notes, 'Previous notes');
  });

  test('updateSupersetGroup correctly updates database', () async {
    await dataSource.updateSupersetGroup(1, 2, 5);
    expect(dbHelper.fakeDb.updatedRecords.isNotEmpty, true);
    final lastUpdate = dbHelper.fakeDb.updatedRecords.last;
    expect(lastUpdate['table'], 'routine_exercise_cross_ref');
    expect(lastUpdate['values']['supersetGroup'], 5);
    expect(lastUpdate['where'], 'routineId = ? AND exerciseId = ?');
    expect(lastUpdate['whereArgs'], [1, 2]);

    // Test nullable update
    await dataSource.updateSupersetGroup(1, 2, null);
    final nullableUpdate = dbHelper.fakeDb.updatedRecords.last;
    expect(nullableUpdate['values']['supersetGroup'], null);
  });
}
