import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../../features/workout/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/session_detail_screen.dart';
import '../../features/workout/presentation/screens/routine_list_screen.dart';
import '../../features/workout/presentation/screens/routine_edit_screen.dart';
import '../../features/workout/presentation/screens/exercise_selection_screen.dart';
import '../../features/workout/presentation/screens/exercise_library_screen.dart';
import '../../features/program/presentation/screens/program_edit_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/body_weight_screen.dart';
import '../../features/workout/presentation/screens/workout_summary_screen.dart';
import '../../features/workout/presentation/screens/exercise_detail_screen.dart';

abstract class RouteNames {
  static const splash = 'splash';
  static const home = 'home';
  static const activeWorkout = 'active_workout';
  static const workoutHistory = 'workout_history';
  static const sessionDetail = 'session_detail';
  static const routineList = 'routine_list';
  static const routineEdit = 'routine_edit';
  static const routineNew = 'routine_new';
  static const exerciseSelection = 'exercise_selection';
  static const exerciseLibrary = 'exercise_library';
  static const programNew = 'program_new';
  static const programEdit = 'program_edit';
  static const profileSettings = 'profile_settings';
  static const bodyWeightHistory = 'body_weight_history';
  static const workoutSummary = 'workout_summary';
  static const exerciseDetail = 'exercise_detail';
}

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Routines
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/routines',
              name: RouteNames.routineList,
              builder: (context, state) => const RoutineListScreen(),
              routes: [
                GoRoute(
                  path: 'edit/:routineId',
                  name: RouteNames.routineEdit,
                  builder: (context, state) {
                    final routineId = int.parse(state.pathParameters['routineId']!);
                    return RoutineEditScreen(routineId: routineId);
                  },
                ),
                GoRoute(
                  path: 'new',
                  name: RouteNames.routineNew,
                  builder: (context, state) => const RoutineEditScreen(),
                ),
                GoRoute(
                  path: ':routineId/add-exercise',
                  name: RouteNames.exerciseSelection,
                  builder: (context, state) {
                    final routineId = int.parse(state.pathParameters['routineId']!);
                    return ExerciseSelectionScreen(routineId: routineId);
                  },
                ),
                GoRoute(
                  path: 'programs/new',
                  name: RouteNames.programNew,
                  builder: (context, state) => const ProgramEditScreen(),
                ),
                GoRoute(
                  path: 'programs/:programId',
                  name: RouteNames.programEdit,
                  builder: (context, state) {
                    final programId = int.parse(state.pathParameters['programId']!);
                    return ProgramEditScreen(programId: programId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: RouteNames.workoutHistory,
              builder: (context, state) => const WorkoutHistoryScreen(),
              routes: [
                GoRoute(
                  path: ':sessionId',
                  name: RouteNames.sessionDetail,
                  builder: (context, state) {
                    final sessionId = int.parse(state.pathParameters['sessionId']!);
                    return SessionDetailScreen(sessionId: sessionId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Full-screen overlays
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/workout',
      name: RouteNames.activeWorkout,
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
    GoRoute(
      path: '/exercises',
      name: RouteNames.exerciseLibrary,
      builder: (context, state) => const ExerciseLibraryScreen(),
    ),
    GoRoute(
      path: '/profile_settings',
      name: RouteNames.profileSettings,
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: '/body-weight-history',
      name: RouteNames.bodyWeightHistory,
      builder: (context, state) => const BodyWeightScreen(),
    ),
    GoRoute(
      path: '/workout-summary/:sessionId',
      name: RouteNames.workoutSummary,
      builder: (context, state) {
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        return WorkoutSummaryScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/exercise-detail/:id',
      name: RouteNames.exerciseDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ExerciseDetailScreen(exerciseId: id);
      },
    ),
  ],
);
