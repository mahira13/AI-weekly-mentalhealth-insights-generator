import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/constants.dart';
import '../../data/services/insights_model_setup_service.dart';

class InsightsModelInstallGate extends StatefulWidget {
  const InsightsModelInstallGate({required this.child, super.key});

  final Widget child;

  @override
  State<InsightsModelInstallGate> createState() =>
      _InsightsModelInstallGateState();
}

class _InsightsModelInstallGateState extends State<InsightsModelInstallGate> {
  bool _hasCheckedPrompt = false;

  InsightsModelSetupService get _modelSetupService =>
      sl<InsightsModelSetupService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrompt());
  }

  @override
  Widget build(BuildContext context) => widget.child;

  BuildContext? get _navigatorContext => appNavigatorKey.currentContext;
  NavigatorState? get _navigator => appNavigatorKey.currentState;

  Future<void> _checkPrompt() async {
    if (_hasCheckedPrompt || !mounted) {
      return;
    }
    _hasCheckedPrompt = true;

    final shouldPrompt = await _modelSetupService.shouldPromptOnLaunch();
    if (!mounted || !shouldPrompt || _navigatorContext == null) {
      return;
    }

    final shouldInstall = await showDialog<bool>(
      context: _navigatorContext!,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enable Offline Weekly Insights?'),
          content: Text(
            'Weekly insights can run privately on this device by installing '
            '${AppConstants.gemmaModelDisplayName}. The model download is about '
            '${AppConstants.gemmaModelApproxSizeMb} MB and keeps your journal '
            'analysis available offline after setup.',
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Install Model'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldInstall == null) {
      return;
    }

    if (!shouldInstall) {
      await _modelSetupService.declineInstallConsent();
      return;
    }

    await _modelSetupService.acceptInstallConsent();
    await _installWithFeedback();
  }

  Future<void> _installWithFeedback() async {
    final progress = ValueNotifier<int>(0);
    if (_navigatorContext == null) {
      progress.dispose();
      return;
    }

    showDialog<void>(
      context: _navigatorContext!,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Installing Offline Model'),
          content: ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (context, value, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downloading ${AppConstants.gemmaModelDisplayName} for '
                    'private weekly insights.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: value / 100),
                  const SizedBox(height: 12),
                  Text('$value% complete'),
                ],
              );
            },
          ),
        );
      },
    );

    try {
      await _modelSetupService.installModel(onProgress: (value) {
        progress.value = value.clamp(0, 100);
      });
      if (mounted) {
        _navigator?.pop();
        appScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Offline weekly insights is ready on this device.'),
          ),
        );
      }
    } on Failure catch (failure) {
      if (mounted) {
        _navigator?.pop();
        await _showInstallError(failure.message);
      }
    } finally {
      progress.dispose();
    }
  }

  Future<void> _showInstallError(String message) {
    final navigatorContext = _navigatorContext;
    if (navigatorContext == null) {
      return Future<void>.value();
    }

    return showDialog<void>(
      context: navigatorContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Model Install Failed'),
          content: Text(
            message,
            style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
