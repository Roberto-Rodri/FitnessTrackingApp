import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/workout/domain/exceptions/workout_exceptions.dart';

abstract class BackupLocalDataSource {
  Future<String> exportDatabase();
  Future<void> importDatabase(String jsonString);
}

class BackupLocalDataSourceImpl implements BackupLocalDataSource {
  final DatabaseHelper _databaseHelper;

  BackupLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<String> exportDatabase() async {
    try {
      final db = await _databaseHelper.database;
      final tablesQuery = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT IN ('android_metadata', 'sqlite_sequence')"
      );

      final Map<String, dynamic> exportData = {
        'version': 8,
        'exportDate': DateTime.now().toIso8601String(),
      };
      
      for (var row in tablesQuery) {
        final tableName = row['name'] as String;
        final tableData = await db.query(tableName);
        exportData[tableName] = tableData;
      }

      final jsonString = jsonEncode(exportData);
      
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${tempDir.path}/ironlog_backup_$dateStr.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw DatabaseOperationException('Failed to export database: $e');
    }
  }

  @override
  Future<void> importDatabase(String jsonString) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonString);
      
      if (importData['version'] != 8) {
        throw const FormatException('This backup was created with a different version of IronLog.');
      }
      
      final db = await _databaseHelper.database;

      await db.transaction((txn) async {
        // Temporarily defer foreign keys within this transaction
        await txn.execute('PRAGMA defer_foreign_keys = ON');

        for (final tableName in importData.keys) {
          if (tableName == 'version' || tableName == 'exportDate') continue;
          
          // Double check if table exists
          final tableExists = Sqflite.firstIntValue(
            await txn.rawQuery("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?", [tableName])
          );
          if (tableExists == 1) {
            await txn.delete(tableName);
          }
        }

        for (final tableName in importData.keys) {
          if (tableName == 'version' || tableName == 'exportDate') continue;

          final tableExists = Sqflite.firstIntValue(
            await txn.rawQuery("SELECT count(*) FROM sqlite_master WHERE type='table' AND name=?", [tableName])
          );
          if (tableExists != 1) continue;

          final rows = importData[tableName] as List<dynamic>;
          for (final row in rows) {
            await txn.insert(tableName, Map<String, dynamic>.from(row));
          }
        }
      });
    } catch (e) {
      throw DatabaseOperationException('Failed to import database: $e');
    }
  }
}
