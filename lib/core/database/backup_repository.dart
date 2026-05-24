import 'backup_local_data_source.dart';

abstract class BackupRepository {
  Future<String> exportDatabase();
  Future<void> importDatabase(String jsonString);
}

class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDataSource _dataSource;

  BackupRepositoryImpl(this._dataSource);

  @override
  Future<String> exportDatabase() {
    return _dataSource.exportDatabase();
  }

  @override
  Future<void> importDatabase(String jsonString) {
    return _dataSource.importDatabase(jsonString);
  }
}
