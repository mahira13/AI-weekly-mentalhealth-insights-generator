/// App-wide string constants and configuration keys.
class AppConstants {
  AppConstants._();

  // ── Hive box names ──────────────────────────────────────────────────────────
  static const String journalBoxName = 'journal_entries';

  // ── Hive type IDs ──────────────────────────────────────────────────────────
  static const int journalEntryTypeId = 0;

  // ── App settings storage ───────────────────────────────────────────────────
  static const String appSettingsBoxName = 'app_settings';
  static const String insightsModelConsentKey = 'insights_model_consent';

  // ── On-device AI ────────────────────────────────────────────────────────────
  static const String gemmaModelFileName = 'qwen3_0_6b_mixed_int4.litertlm';
  static const String gemmaModelDownloadUrl =
      'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/main/qwen3_0_6b_mixed_int4.litertlm?download=true';
  static const String gemmaModelDisplayName = 'Qwen3 0.6B';
  static const int gemmaModelApproxSizeMb = 498;
  static const int gemmaInsightsMaxTokens = 2048;

  // ── Journal slider ranges ────────────────────────────────────────────────────
  static const double sliderMin = 0;
  static const double sliderMax = 10;
  static const int sliderDivisions = 10;

  // ── Weekly data window ───────────────────────────────────────────────────────
  static const int weekDays = 7;
}
