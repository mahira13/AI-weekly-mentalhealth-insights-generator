import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterGemma.logLevel = GemmaLogLevel.none;
  FlutterGemma.initialize(
    inferenceEngines: const [
      LiteRtLmEngine(),
      MediaPipeEngine(),
    ],
  );

  // Initialise Hive, GetIt, and register all dependencies
  await initDependencies();

  runApp(const App());
}
