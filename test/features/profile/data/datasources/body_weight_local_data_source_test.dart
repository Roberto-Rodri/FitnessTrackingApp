import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:iron_log/core/database/database_helper.dart';
import 'package:iron_log/features/workout/data/datasources/workout_local_data_source.dart';
import 'package:iron_log/features/workout/domain/entities/body_weight_log.dart';

class FakeDatabase implements Database {
  final List<Map<String, dynamic>> insertedRecords = [];
  final List<Map<String, dynamic>> deletedRecords = [];

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    insertedRecords.add({'table': table, 'values': values});
    return 1;
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    deletedRecords.add({'table': table, 'where': where, 'whereArgs': whereArgs});
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    return [
      {
        'id': 'log-1',
        'timestamp': 1600000000,
        'weight': 75.5,
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

  test('inserting body weight log', () async {
    final log = BodyWeightLog(id: 'log-1', date: DateTime.fromMillisecondsSinceEpoch(1600000000), weight: 75.5);
    await dataSource.saveBodyWeightLog(log);
    expect(dbHelper.fakeDb.insertedRecords.length, 1);
    expect(dbHelper.fakeDb.insertedRecords.first['table'], 'body_weight_logs');
    expect(dbHelper.fakeDb.insertedRecords.first['values']['weight'], 75.5);
  });

  test('deleting body weight log', () async {
    await dataSource.deleteBodyWeightLog('log-1');
    expect(dbHelper.fakeDb.deletedRecords.length, 1);
    expect(dbHelper.fakeDb.deletedRecords.first['table'], 'body_weight_logs');
    expect(dbHelper.fakeDb.deletedRecords.first['whereArgs'], ['log-1']);
  });

  test('fetching body weight logs', () async {
    final logs = await dataSource.getBodyWeightLogs();
    expect(logs.length, 1);
    expect(logs.first.id, 'log-1');
    expect(logs.first.weight, 75.5);
  });
}
