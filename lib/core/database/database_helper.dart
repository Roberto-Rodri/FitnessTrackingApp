import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "IronLog.db";
  static const _databaseVersion = 6;

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
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable SQLite foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE workout_sets_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sessionId INTEGER NOT NULL,
          exerciseId INTEGER NOT NULL,
          weight REAL NOT NULL,
          reps INTEGER NOT NULL,
          rpe INTEGER,
          FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
          FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');
      
      await db.execute('INSERT INTO workout_sets_new SELECT * FROM workout_sets');
      await db.execute('DROP TABLE workout_sets');
      await db.execute('ALTER TABLE workout_sets_new RENAME TO workout_sets');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE routine_exercise_cross_ref ADD COLUMN restSeconds INTEGER NOT NULL DEFAULT 90');
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE exercises ADD COLUMN weightUnit TEXT NOT NULL DEFAULT 'kg'");
      await db.execute('ALTER TABLE workout_sets ADD COLUMN customWeight TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS exercise_alternatives (
          exerciseId1 INTEGER NOT NULL,
          exerciseId2 INTEGER NOT NULL,
          PRIMARY KEY (exerciseId1, exerciseId2),
          FOREIGN KEY (exerciseId1) REFERENCES exercises (id) ON DELETE CASCADE,
          FOREIGN KEY (exerciseId2) REFERENCES exercises (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS programs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          cycleLengthDays INTEGER NOT NULL,
          isActive INTEGER NOT NULL DEFAULT 0,
          currentDayIndex INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS program_days (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          programId INTEGER NOT NULL,
          dayIndex INTEGER NOT NULL,
          routineId INTEGER,
          label TEXT NOT NULL,
          FOREIGN KEY (programId) REFERENCES programs (id) ON DELETE CASCADE,
          FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE SET NULL
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bodyPart TEXT NOT NULL,
        weightUnit TEXT NOT NULL DEFAULT 'kg'
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
        restSeconds INTEGER NOT NULL DEFAULT 90,
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
        customWeight TEXT,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE exercise_alternatives (
        exerciseId1 INTEGER NOT NULL,
        exerciseId2 INTEGER NOT NULL,
        PRIMARY KEY (exerciseId1, exerciseId2),
        FOREIGN KEY (exerciseId1) REFERENCES exercises (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId2) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE programs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cycleLengthDays INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 0,
        currentDayIndex INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE program_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        programId INTEGER NOT NULL,
        dayIndex INTEGER NOT NULL,
        routineId INTEGER,
        label TEXT NOT NULL,
        FOREIGN KEY (programId) REFERENCES programs (id) ON DELETE CASCADE,
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE SET NULL
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
      'restSeconds': 90,
    });
    await db.insert('routine_exercise_cross_ref', {
      'routineId': routineId,
      'exerciseId': benchId,
      'sequenceOrder': 2,
      'targetSets': 3,
      'targetReps': '8-10',
      'restSeconds': 90,
    });
    await db.insert('routine_exercise_cross_ref', {
      'routineId': routineId,
      'exerciseId': deadliftId,
      'sequenceOrder': 3,
      'targetSets': 3,
      'targetReps': '5',
      'restSeconds': 120,
    });

    // Additional exercises
    // Chest
    await db.insert('exercises', {'name': 'Incline Bench Press', 'bodyPart': 'Chest'});
    await db.insert('exercises', {'name': 'Dumbbell Fly', 'bodyPart': 'Chest'});
    await db.insert('exercises', {'name': 'Cable Crossover', 'bodyPart': 'Chest'});
    await db.insert('exercises', {'name': 'Push-Up', 'bodyPart': 'Chest'});
    await db.insert('exercises', {'name': 'Chest Dip', 'bodyPart': 'Chest'});

    // Back
    await db.insert('exercises', {'name': 'Barbell Row', 'bodyPart': 'Back'});
    await db.insert('exercises', {'name': 'Pull-Up', 'bodyPart': 'Back'});
    await db.insert('exercises', {'name': 'Lat Pulldown', 'bodyPart': 'Back'});
    await db.insert('exercises', {'name': 'Seated Cable Row', 'bodyPart': 'Back'});
    await db.insert('exercises', {'name': 'T-Bar Row', 'bodyPart': 'Back'});
    await db.insert('exercises', {'name': 'Face Pull', 'bodyPart': 'Back'});

    // Legs
    await db.insert('exercises', {'name': 'Leg Press', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Romanian Deadlift', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Leg Curl', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Leg Extension', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Walking Lunge', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Calf Raise', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Bulgarian Split Squat', 'bodyPart': 'Legs'});
    await db.insert('exercises', {'name': 'Hip Thrust', 'bodyPart': 'Legs'});

    // Shoulders
    await db.insert('exercises', {'name': 'Overhead Press', 'bodyPart': 'Shoulders'});
    await db.insert('exercises', {'name': 'Lateral Raise', 'bodyPart': 'Shoulders'});
    await db.insert('exercises', {'name': 'Front Raise', 'bodyPart': 'Shoulders'});
    await db.insert('exercises', {'name': 'Rear Delt Fly', 'bodyPart': 'Shoulders'});
    await db.insert('exercises', {'name': 'Arnold Press', 'bodyPart': 'Shoulders'});
    await db.insert('exercises', {'name': 'Shrug', 'bodyPart': 'Shoulders'});

    // Arms
    await db.insert('exercises', {'name': 'Barbell Curl', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Hammer Curl', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Tricep Pushdown', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Overhead Tricep Extension', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Skull Crusher', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Concentration Curl', 'bodyPart': 'Arms'});
    await db.insert('exercises', {'name': 'Dip', 'bodyPart': 'Arms'});

    // Core
    await db.insert('exercises', {'name': 'Plank', 'bodyPart': 'Core'});
    await db.insert('exercises', {'name': 'Cable Crunch', 'bodyPart': 'Core'});
    await db.insert('exercises', {'name': 'Hanging Leg Raise', 'bodyPart': 'Core'});
    await db.insert('exercises', {'name': 'Russian Twist', 'bodyPart': 'Core'});
    await db.insert('exercises', {'name': 'Ab Wheel Rollout', 'bodyPart': 'Core'});
  }
}    
