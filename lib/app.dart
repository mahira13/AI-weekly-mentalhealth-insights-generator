import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/insights/presentation/widgets/insights_model_install_gate.dart';

/// Root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mental Health Insights',
      theme: AppTheme.light,
      routerConfig: appRouter,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => InsightsModelInstallGate(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
