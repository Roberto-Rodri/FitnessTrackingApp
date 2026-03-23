import 'package:go_router/go_router.dart';
import '../../features/workout/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/workout',
      name: 'active_workout',
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
  ],
);
