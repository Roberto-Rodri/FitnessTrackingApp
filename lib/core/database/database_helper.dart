import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "IronLog.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable SQLite foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bodyPart TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercise_cross_ref (
        routineId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        sequenceOrder INTEGER NOT NULL,
        targetSets INTEGER NOT NULL,
        targetReps TEXT NOT NULL,
        PRIMARY KEY (routineId, exerciseId),
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTimestamp INTEGER NOT NULL,
        endTimestamp INTEGER,
        routineId INTEGER,
        routineNameSnapshot TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId INTEGER NOT NULL,
        exerciseId INTEGER NOT NULL,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        rpe INTEGER,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id)
      )
    ''');
    
    await _seedDatabase(db);
  }

  Future _seedDatabase(Database db) async {
    // Check if empty
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM exercises'));
    if (count != null && count > 0) return;

    // Seed Exercises
    final squatId = await db.insert('exercises', {'name': 'Squat', 'bodyPart': 'Legs'});
    final benchId = await db.insert('exercises', {'name': 'Bench Press', 'bodyPart': 'Chest'});
    final deadliftId = await db.insert('exercises', {'name': 'Deadlift', 'bodyPart': 'Back'});

    // Seed Routine
    final routineId = await db.insert('routines', {'name': 'Full Body Starter'});

    // Seed Cross Refs
    await db.insert('routine_exercise_cross_ref', {
      'routineId': routineId,
      'exerciseId': squatId,
      'sequenceOrder': 1,
      'targetSets': 3,
      'targetReps': '8-10',
    });
    await db.insert('routine_exercise_cross_ref', {
      'routineId': routineId,
      'exerciseId': benchId,
      'sequenceOrder': 2,
      'targetSets': 3,
      'targetReps': '8-10',
    });
    await db.insert('routine_exercise_cross_ref', {
      'routineId': routineId,
      'exerciseId': deadliftId,
      'sequenceOrder': 3,
      'targetSets': 3,
      'targetReps': '5',
    });
  }
}    
