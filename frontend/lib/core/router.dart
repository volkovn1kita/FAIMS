import 'package:go_router/go_router.dart';
import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/home_screen.dart';
import 'package:frontend/presentation/screens/user_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
        return HomeScreen(
          userName: extra['userName']?.toString() ?? '',
          userRole: extra['userRole']?.toString() ?? 'Administrator',
        );
      },
    ),
    GoRoute(
      path: '/user-home',
      builder: (context, state) {
        final userName = state.extra as String? ?? '';
        return UserHomeScreen(userName: userName);
      },
    ),
  ],
);
