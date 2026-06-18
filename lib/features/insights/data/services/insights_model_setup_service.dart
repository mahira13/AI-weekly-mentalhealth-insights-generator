import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:hive/hive.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';

enum InsightsModelConsentStatus {
  undecided,
  accepted,
  declined,
}

class InsightsModelSetupService {
  const InsightsModelSetupService({required this.box});

  final Box<dynamic> box;

  Future<bool> isModelInstalled() {
    return FlutterGemma.isModelInstalled(AppConstants.gemmaModelFileName);
  }

  InsightsModelConsentStatus getConsentStatus() {
    final rawValue = box.get(AppConstants.insightsModelConsentKey) as String?;
    return switch (rawValue) {
      'accepted' => InsightsModelConsentStatus.accepted,
      'declined' => InsightsModelConsentStatus.declined,
      _ => InsightsModelConsentStatus.undecided,
    };
  }

  Future<bool> shouldPromptOnLaunch() async {
    if (await isModelInstalled()) {
      return false;
    }

    return getConsentStatus() == InsightsModelConsentStatus.undecided;
  }

  Future<void> acceptInstallConsent() {
    return box.put(AppConstants.insightsModelConsentKey, 'accepted');
  }

  Future<void> declineInstallConsent() {
    return box.put(AppConstants.insightsModelConsentKey, 'declined');
  }

  Future<void> installModel({void Function(int progress)? onProgress}) async {
    try {
      await FlutterGemma.installModel(
        modelType: ModelType.qwen3,
        fileType: ModelFileType.litertlm,
      )
          .fromNetwork(
        AppConstants.gemmaModelDownloadUrl,
      )
          .withProgress((progress) {
        onProgress?.call(progress);
      }).install();
      onProgress?.call(100);
    } catch (error) {
      throw ServerFailure(
        'Could not install the local weekly insights model. Please check your '
        'connection and free storage, then try again.\n\n$error',
      );
    }
  }

  Future<void> ensureModelReady() async {
    if (await isModelInstalled()) {
      await installModel();
      return;
    }

    switch (getConsentStatus()) {
      case InsightsModelConsentStatus.accepted:
        await installModel();
      case InsightsModelConsentStatus.undecided:
        throw const ServerFailure(
          'Weekly insights uses a private on-device '
          '${AppConstants.gemmaModelDisplayName} model of about '
          '${AppConstants.gemmaModelApproxSizeMb} MB. Accept the model '
          'install prompt to enable offline insights.',
        );
      case InsightsModelConsentStatus.declined:
        throw const ServerFailure(
          'The on-device weekly insights model was not installed. To use '
          'offline insights, allow the '
          '${AppConstants.gemmaModelApproxSizeMb} MB model download when prompted.',
        );
    }
  }
}
