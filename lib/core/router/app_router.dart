import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/journal/presentation/pages/timeline_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';

/// Named route paths used throughout the app.
class AppRoutes {
  AppRoutes._();

  static const String journal = '/';
  static const String timeline = '/timeline';
  static const String insights = '/insights';
}

/// Configures [GoRouter] with all application routes.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.journal,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.journal,
      name: 'journal',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: JournalPage()),
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
