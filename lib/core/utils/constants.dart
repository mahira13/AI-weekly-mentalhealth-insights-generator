/// App-wide string constants and configuration keys.
class AppConstants {
  AppConstants._();

  // ── Hive box names ──────────────────────────────────────────────────────────
  static const String journalBoxName = 'journal_entries';

  // ── Hive type IDs ──────────────────────────────────────────────────────────
  static const int journalEntryTypeId = 0;

  // ── Environment variable keys ───────────────────────────────────────────────
  static const String openAiApiKeyEnv = 'OPENAI_API_KEY';
  static const String claudeApiKeyEnv = 'CLAUDE_API_KEY';
  static const String aiProviderEnv = 'AI_PROVIDER';

  // ── AI provider identifiers ─────────────────────────────────────────────────
  static const String providerOpenAi = 'openai';
  static const String providerClaude = 'claude';

  // ── OpenAI endpoint ─────────────────────────────────────────────────────────
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiChatEndpoint = '$openAiBaseUrl/chat/completions';
  static const String openAiModel = 'gpt-4o-mini';

  // ── Claude endpoint ─────────────────────────────────────────────────────────
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeMessagesEndpoint = '$claudeBaseUrl/messages';
  static const String claudeModel = 'claude-3-haiku-20240307';
  static const String claudeVersion = '2023-06-01';

  // ── Journal slider ranges ────────────────────────────────────────────────────
  static const double sliderMin = 0;
  static const double sliderMax = 10;
  static const int sliderDivisions = 10;

  // ── Weekly data window ───────────────────────────────────────────────────────
  static const int weekDays = 7;
}
