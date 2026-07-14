import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:iron_log/core/di/injection.dart';
import 'package:iron_log/features/program/domain/entities/program.dart';
import 'package:iron_log/features/program/domain/entities/program_day.dart';
import 'package:iron_log/features/program/domain/entities/program_detail.dart';
import 'package:iron_log/features/program/domain/repositories/program_repository.dart';
import 'package:iron_log/features/program/presentation/controllers/program_providers.dart';
import 'package:iron_log/features/program/presentation/screens/program_edit_screen.dart';
import 'package:iron_log/features/workout/domain/entities/routine_summary.dart';
import 'package:iron_log/features/workout/presentation/controllers/workout_providers.dart';

class _FakeProgramRepository implements ProgramRepository {
  @override
  Future<void> updateProgram(int id, String name, List<ProgramDay> days) async {}

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

void main() {
  testWidgets('rename program day Legs -> Legs A does not crash', (tester) async {
    const detail = ProgramDetail(
      program: Program(id: 1, name: 'PPL', cycleLengthDays: 3, isActive: true),
      days: [
        ProgramDay(id: 1, programId: 1, dayIndex: 0, routineId: 10, label: 'Legs'),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          programRepositoryProvider.overrideWithValue(_FakeProgramRepository()),
          programDetailProvider(1).overrideWith((ref) async => detail),
          routineListProvider.overrideWith(
            (ref) async => const [
              RoutineSummary(id: 10, name: 'Legs Routine', exerciseCount: 4),
            ],
          ),
        ],
        child: const MaterialApp(
          home: ProgramEditScreen(programId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Sanity: the day card is shown.
    expect(find.text('Day 1 · Legs'), findsOneWidget);

    // Tap the edit (rename) icon on the day card.
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Dialog is open.
    expect(find.text('Rename day'), findsOneWidget);

    // Rename to "Legs A".
    await tester.enterText(find.byType(TextField).last, 'Legs A');
    await tester.pump();

    // Tap the dialog's Save (there is also a Save in the app bar).
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('Save')),
    );
    await tester.pumpAndSettle();

    // If the '_dependents.isEmpty' assertion fired, it surfaces here.
    expect(tester.takeException(), isNull);

    // Rename should have applied.
    expect(find.text('Day 1 · Legs A'), findsOneWidget);
  });
}
