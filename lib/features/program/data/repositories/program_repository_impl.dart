import '../../domain/entities/program.dart';
import '../../domain/entities/program_day.dart';
import '../../domain/entities/program_detail.dart';
import '../../domain/repositories/program_repository.dart';
import '../datasources/program_local_data_source.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  final ProgramLocalDataSource localDataSource;

  ProgramRepositoryImpl(this.localDataSource);

  @override
  Future<List<Program>> getAllPrograms() {
    return localDataSource.getAllPrograms();
  }

  @override
  Future<ProgramDetail> getProgramDetail(int programId) {
    return localDataSource.getProgramDetail(programId);
  }

  @override
  Future<Program?> getActiveProgram() {
    return localDataSource.getActiveProgram();
  }

  @override
  Future<List<ProgramDay>> getProgramDays(int programId) {
    return localDataSource.getProgramDays(programId);
  }

  @override
  Future<ProgramDay?> getCurrentDay(int programId) {
    return localDataSource.getCurrentDay(programId);
  }

  @override
  Future<int> createProgram(String name, List<ProgramDay> days) {
    return localDataSource.createProgram(name, days);
  }

  @override
  Future<void> updateProgram(int id, String name, List<ProgramDay> days) {
    return localDataSource.updateProgram(id, name, days);
  }

  @override
  Future<void> deleteProgram(int programId) {
    return localDataSource.deleteProgram(programId);
  }

  @override
  Future<void> setActiveProgram(int programId) {
    return localDataSource.setActiveProgram(programId);
  }

  @override
  Future<void> deactivateAllPrograms() {
    return localDataSource.deactivateAllPrograms();
  }

  @override
  Future<void> advanceCycleDay(int programId) {
    return localDataSource.advanceCycleDay(programId);
  }
}
