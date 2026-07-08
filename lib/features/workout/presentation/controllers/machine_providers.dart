import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/machine.dart';

part 'machine_providers.g.dart';

@riverpod
class MachinesNotifier extends _$MachinesNotifier {
  @override
  Future<List<Machine>> build() async {
    final repository = ref.watch(workoutRepositoryProvider);
    return repository.getAllMachines();
  }

  Future<void> createMachine(String name) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.createMachine(name);
    ref.invalidateSelf();
  }

  Future<void> deleteMachine(int machineId) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteMachine(machineId);
    ref.invalidateSelf();
  }
}
