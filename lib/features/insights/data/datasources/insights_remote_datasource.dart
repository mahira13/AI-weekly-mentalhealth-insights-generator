import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../models/weekly_insights_model.dart';

/// Contract for the AI insights remote data source.
abstract class InsightsRemoteDataSource {
  Future<WeeklyInsightsModel> fetchInsights(List<JournalEntry> entries);
}

/// Concrete implementation that supports both OpenAI and Claude.
class InsightsRemoteDataSourceImpl implements InsightsRemoteDataSource {
  final String aiProvider;
  final String openAiApiKey;
  final String claudeApiKey;
  final http.Client _client;

  InsightsRemoteDataSourceImpl({
    required this.aiProvider,
    required this.openAiApiKey,
    this.claudeApiKey = '',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<WeeklyInsightsModel> fetchInsights(
    List<JournalEntry> entries,
  ) async {
    if (entries.isEmpty) {
      throw const ServerFailure(
        'No journal entries found for the past week. '
        'Please log at least one entry before generating insights.',
      );
    }

    final prompt = WeeklyInsightsModel.buildPrompt(entries);

    return switch (aiProvider.toLowerCase()) {
      AppConstants.providerClaude => _fetchFromClaude(prompt),
      _ => _fetchFromOpenAi(prompt),
    };
  }

  // ── OpenAI ─────────────────────────────────────────────────────────────────

  Future<WeeklyInsightsModel> _fetchFromOpenAi(String prompt) async {
    if (openAiApiKey.isEmpty) {
      throw const AuthFailure(
        'OPENAI_API_KEY is not set. Please add it to your .env file.',
      );
    }

    final body = jsonEncode({
      'model': AppConstants.openAiModel,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 500,
    });

    final response = await _client
        .post(
          Uri.parse(AppConstants.openAiChatEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAiApiKey',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    _assertOk(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (decoded['choices'] as List).first['message']['content'] as String;

    return _parseContent(content);
  }

  // ── Claude ─────────────────────────────────────────────────────────────────

  Future<WeeklyInsightsModel> _fetchFromClaude(String prompt) async {
    if (claudeApiKey.isEmpty) {
      throw const AuthFailure(
        'CLAUDE_API_KEY is not set. Please add it to your .env file.',
      );
    }

    final body = jsonEncode({
      'model': AppConstants.claudeModel,
      'max_tokens': 500,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
    });

    final response = await _client
        .post(
          Uri.parse(AppConstants.claudeMessagesEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': claudeApiKey,
            'anthropic-version': AppConstants.claudeVersion,
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    _assertOk(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (decoded['content'] as List).first['text'] as String;

    return _parseContent(content);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertOk(http.Response response) {
    if (response.statusCode == 401) {
      throw const AuthFailure('Invalid or expired API key.');
    }
    if (response.statusCode != 200) {
      throw ServerFailure(
        'AI provider returned ${response.statusCode}: ${response.body}',
      );
    }
  }

  WeeklyInsightsModel _parseContent(String content) {
    try {
      // Strip optional markdown fences if the model wraps in ```json ... ```
      final cleaned = content
          .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return WeeklyInsightsModel.fromJson(json);
    } catch (e) {
      throw ParseFailure('Could not parse AI response: $e\n\nRaw: $content');
    }
  }
}
