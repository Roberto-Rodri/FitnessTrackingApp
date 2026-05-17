import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/program.dart';
import '../../domain/entities/program_day.dart';
import '../../domain/entities/program_detail.dart';
import '../../../../core/di/injection.dart';
import '../../../workout/presentation/controllers/workout_providers.dart';

part 'program_providers.g.dart';

@riverpod
Future<List<Program>> allPrograms(AllProgramsRef ref) async {
  final repository = ref.watch(programRepositoryProvider);
  return repository.getAllPrograms();
}

@riverpod
Future<ProgramDetail?> activeProgram(ActiveProgramRef ref) async {
  final repository = ref.watch(programRepositoryProvider);
  final program = await repository.getActiveProgram();
  if (program == null) return null;
  return repository.getProgramDetail(program.id!);
}

@riverpod
Future<ProgramDetail> programDetail(ProgramDetailRef ref, int programId) async {
  final repository = ref.watch(programRepositoryProvider);
  return repository.getProgramDetail(programId);
}

@riverpod
Future<ProgramDay?> currentProgramDay(CurrentProgramDayRef ref) async {
  final repository = ref.watch(programRepositoryProvider);
  final program = await repository.getActiveProgram();
  if (program == null) return null;
  return repository.getCurrentDay(program.id!);
}

@riverpod
Future<Set<int>> completedProgramDays(CompletedProgramDaysRef ref) async {
  final activeProgram = await ref.watch(activeProgramProvider.future);
  if (activeProgram == null) return {};
  
  final sessions = await ref.watch(completedSessionsProvider.future);
  final days = activeProgram.days;
  
  // Find sessions that match program day routines
  final completedIndices = <int>{};
  for (final day in days) {
    if (day.routineId != null) {
      final hasCompleted = sessions.any((s) => s.session.routineId == day.routineId);
      if (hasCompleted) completedIndices.add(day.dayIndex);
    }
  }
  return completedIndices;
}
