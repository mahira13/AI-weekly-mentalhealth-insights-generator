import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/journal/presentation/pages/home_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/journal/presentation/pages/timeline_page.dart';

/// Named route paths used throughout the app.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String journal = '/journal';
  static const String timeline = '/timeline';
  static const String insights = '/insights';
}

/// Configures [GoRouter] with all application routes.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: HomePage()),
    ),
    GoRoute(
      path: AppRoutes.journal,
      name: 'journal',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final journalBloc = state.extra as JournalBloc?;

        if (journalBloc == null) {
          return const NoTransitionPage(
            child: Scaffold(
              body: Center(
                child: Text('Journal context unavailable.'),
              ),
            ),
          );
        }

        return NoTransitionPage(
          child: BlocProvider.value(
            value: journalBloc,
            child: const JournalPage(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.timeline,
      name: 'timeline',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: TimelinePage()),
    ),
    GoRoute(
      path: AppRoutes.insights,
      name: 'insights',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: InsightsPage()),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
