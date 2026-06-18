import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/journal/presentation/pages/home_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';
import '../../features/journal/presentation/bloc/journal_event.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/journal/presentation/pages/timeline_page.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
  navigatorKey: appNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      pageBuilder: (BuildContext context, GoRouterState state, Widget child) {
        return NoTransitionPage(child: _JournalFlowScope(child: child));
      },
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
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

class _JournalFlowScope extends StatefulWidget {
  const _JournalFlowScope({required this.child});

  final Widget child;

  @override
  State<_JournalFlowScope> createState() => _JournalFlowScopeState();
}

class _JournalFlowScopeState extends State<_JournalFlowScope> {
  late final JournalBloc _journalBloc;

  @override
  void initState() {
    super.initState();
    _journalBloc = sl<JournalBloc>()..add(const LoadWeeklyEntries());
  }

  @override
  void dispose() {
    _journalBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _journalBloc,
      child: widget.child,
    );
  }
}
