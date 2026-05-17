import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/body_weight_log.dart';

part 'body_weight_providers.g.dart';

@riverpod
class BodyWeightLogsNotifier extends _$BodyWeightLogsNotifier {
  @override
  Future<List<BodyWeightLog>> build() async {
    final repository = ref.watch(workoutRepositoryProvider);
    return repository.getBodyWeightLogs();
  }

  Future<void> addLog(double weight) async {
    final repository = ref.read(workoutRepositoryProvider);
    final log = BodyWeightLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weight: weight,
    );
    await repository.saveBodyWeightLog(log);
    ref.invalidateSelf();
  }

  Future<void> deleteLog(String id) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteBodyWeightLog(id);
    ref.invalidateSelf();
  }
}
