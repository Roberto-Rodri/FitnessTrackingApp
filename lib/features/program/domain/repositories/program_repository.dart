import '../entities/program.dart';
import '../entities/program_day.dart';
import '../entities/program_detail.dart';

abstract class ProgramRepository {
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
