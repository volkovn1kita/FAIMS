import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:faims/presentation/screens/login_screen.dart';
import 'package:faims/presentation/screens/home_screen.dart';
import 'package:faims/presentation/screens/user_home_screen.dart';
import 'package:faims/presentation/screens/privacy_policy_screen.dart';
import 'package:faims/utils/privacy_consent_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    // Never redirect when already on the privacy screen (avoid infinite loop)
    if (state.matchedLocation == '/privacy-policy') return null;
    final accepted = await PrivacyConsentService().isAccepted();
    if (!accepted) return '/privacy-policy';
    return null;
  },
  routes: [
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PrivacyPolicyScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: animation.drive(tween), child: child),
          );
        },
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(
            userName: extra['userName']?.toString() ?? '',
            userRole: extra['userRole']?.toString() ?? 'Administrator',
          ),
          transitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: animation.drive(tween), child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/user-home',
      pageBuilder: (context, state) {
        final userName = state.extra as String? ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: UserHomeScreen(userName: userName),
          transitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: animation.drive(tween), child: child),
            );
          },
        );
      },
    ),
  ],
);
