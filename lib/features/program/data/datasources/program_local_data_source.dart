import '../../../../core/database/database_helper.dart';
import '../../domain/entities/program.dart';
import '../../domain/entities/program_day.dart';
import '../../domain/entities/program_detail.dart';
import '../../../workout/domain/exceptions/workout_exceptions.dart';

abstract class ProgramLocalDataSource {
  Future<List<Program>> getAllPrograms();
  Future<ProgramDetail> getProgramDetail(int programId);
  Future<Program?> getActiveProgram();
  Future<List<ProgramDay>> getProgramDays(int programId);
  Future<ProgramDay?> getCurrentDay(int programId);
  Future<int> createProgram(String name, List<ProgramDay> days);
  Future<void> updateProgram(int id, String name, List<ProgramDay> days);
  Future<void> deleteProgram(int programId);
  Future<void> setActiveProgram(int programId);
  Future<void> deactivateAllPrograms();
  Future<void> advanceCycleDay(int programId);
}

class ProgramLocalDataSourceImpl implements ProgramLocalDataSource {
  final DatabaseHelper dbHelper;

  ProgramLocalDataSourceImpl(this.dbHelper);

  @override
  Future<List<Program>> getAllPrograms() async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query('programs', orderBy: 'name ASC');
      return maps.map((e) => Program.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to get all programs: $e');
    }
  }

  @override
  Future<ProgramDetail> getProgramDetail(int programId) async {
    try {
      final db = await dbHelper.database;
      final programMaps = await db.query('programs', where: 'id = ?', whereArgs: [programId]);
      if (programMaps.isEmpty) {
        throw DatabaseOperationException('Program not found');
      }
      final program = Program.fromJson(programMaps.first);

      final daysMaps = await db.query('program_days', where: 'programId = ?', whereArgs: [programId], orderBy: 'dayIndex ASC');
      final days = daysMaps.map((e) => ProgramDay.fromJson(e)).toList();

      return ProgramDetail(program: program, days: days);
    } catch (e) {
      throw DatabaseOperationException('Failed to get program detail: $e');
    }
  }

  @override
  Future<Program?> getActiveProgram() async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query('programs', where: 'isActive = 1', limit: 1);
      if (maps.isEmpty) return null;
      return Program.fromJson(maps.first);
    } catch (e) {
      throw DatabaseOperationException('Failed to get active program: $e');
    }
  }

  @override
  Future<List<ProgramDay>> getProgramDays(int programId) async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query('program_days', where: 'programId = ?', whereArgs: [programId], orderBy: 'dayIndex ASC');
      return maps.map((e) => ProgramDay.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseOperationException('Failed to get program days: $e');
    }
  }

  @override
  Future<ProgramDay?> getCurrentDay(int programId) async {
    try {
      final db = await dbHelper.database;
      final programMaps = await db.query('programs', where: 'id = ?', whereArgs: [programId]);
      if (programMaps.isEmpty) return null;
      final program = Program.fromJson(programMaps.first);

      final daysMaps = await db.query('program_days', where: 'programId = ?', whereArgs: [programId], orderBy: 'dayIndex ASC');
      final days = daysMaps.map((e) => ProgramDay.fromJson(e)).toList();

      if (days.isEmpty) return null;

      int startIdx = program.currentDayIndex;
      if (startIdx < 0 || startIdx >= days.length) {
        startIdx = 0;
      }

      // 3. If it's a rest day (label == 'rest'), find the next non-rest day (wrapping around)
      for (int i = 0; i < days.length; i++) {
        final checkIdx = (startIdx + i) % days.length;
        if (days[checkIdx].label.toLowerCase() != 'rest') {
          return days[checkIdx];
        }
      }

      // If all are rest days, return the current one anyway or null
      return days[startIdx];
    } catch (e) {
      throw DatabaseOperationException('Failed to get current day: $e');
    }
  }

  @override
  Future<int> createProgram(String name, List<ProgramDay> days) async {
    try {
      final db = await dbHelper.database;
      return await db.transaction((txn) async {
        int firstNonRestDay = 0;
        for (int i = 0; i < days.length; i++) {
          if (days[i].label.toLowerCase() != 'rest') {
            firstNonRestDay = i;
            break;
          }
        }

        final programId = await txn.insert('programs', {
          'name': name,
          'cycleLengthDays': days.length,
          'isActive': 0,
          'currentDayIndex': firstNonRestDay,
        });

        for (final day in days) {
          final dayMap = day.toJson();
          dayMap['programId'] = programId;
          dayMap.remove('id'); // let sqlite auto increment
          await txn.insert('program_days', dayMap);
        }

        return programId;
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to create program: $e');
    }
  }

  @override
  Future<void> updateProgram(int id, String name, List<ProgramDay> days) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.update(
          'programs',
          {
            'name': name,
            'cycleLengthDays': days.length,
          },
          where: 'id = ?',
          whereArgs: [id],
        );

        await txn.delete('program_days', where: 'programId = ?', whereArgs: [id]);

        for (final day in days) {
          final dayMap = day.toJson();
          dayMap['programId'] = id;
          dayMap.remove('id');
          await txn.insert('program_days', dayMap);
        }
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to update program: $e');
    }
  }

  @override
  Future<void> deleteProgram(int programId) async {
    try {
      final db = await dbHelper.database;
      await db.delete('programs', where: 'id = ?', whereArgs: [programId]);
    } catch (e) {
      throw DatabaseOperationException('Failed to delete program: $e');
    }
  }

  @override
  Future<void> setActiveProgram(int programId) async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.update('programs', {'isActive': 0}, where: 'isActive = 1');
        await txn.update('programs', {'isActive': 1}, where: 'id = ?', whereArgs: [programId]);
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to set active program: $e');
    }
  }

  @override
  Future<void> deactivateAllPrograms() async {
    try {
      final db = await dbHelper.database;
      await db.update('programs', {'isActive': 0}, where: 'isActive = 1');
    } catch (e) {
      throw DatabaseOperationException('Failed to deactivate all programs: $e');
    }
  }

  @override
  Future<void> advanceCycleDay(int programId) async {
    try {
      final db = await dbHelper.database;
      final programMaps = await db.query('programs', where: 'id = ?', whereArgs: [programId]);
      if (programMaps.isEmpty) return;
      final program = Program.fromJson(programMaps.first);

      final daysMaps = await db.query('program_days', where: 'programId = ?', whereArgs: [programId], orderBy: 'dayIndex ASC');
      final days = daysMaps.map((e) => ProgramDay.fromJson(e)).toList();
      
      if (days.isEmpty) return;

      int nextIdx = (program.currentDayIndex + 1) % program.cycleLengthDays;
      
      // Skip rest days
      int safetyCounter = 0;
      while (safetyCounter < program.cycleLengthDays) {
        // find the day with dayIndex == nextIdx, if it exists
        final day = days.firstWhere((d) => d.dayIndex == nextIdx, orElse: () => days[0]);
        if (day.label.toLowerCase() != 'rest') {
          break;
        }
        nextIdx = (nextIdx + 1) % program.cycleLengthDays;
        safetyCounter++;
      }

      await db.update('programs', {'currentDayIndex': nextIdx}, where: 'id = ?', whereArgs: [programId]);
    } catch (e) {
      throw DatabaseOperationException('Failed to advance cycle day: $e');
    }
  }
}
