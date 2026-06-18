import 'package:flutter_gemma/flutter_gemma.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../services/insights_model_setup_service.dart';
import '../services/weekly_insights_refiner.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../models/weekly_insights_model.dart';

abstract class InsightsLocalDataSource {
  Future<WeeklyInsightsModel> fetchInsights(List<JournalEntry> entries);
}

class InsightsLocalDataSourceImpl implements InsightsLocalDataSource {
  const InsightsLocalDataSourceImpl({required this.modelSetupService});

  final InsightsModelSetupService modelSetupService;

  static const String _systemInstruction =
      'You are a calm, clinically respectful mental health journaling assistant. '
      'You identify concrete patterns across the week, describe them without '
      'diagnosis or certainty, and explain what looked supportive, what looked '
      'difficult, and what may deserve attention next. You must use the note '
      'text as part of the analysis instead of ignoring it. Write like a '
      'gentle interpreter of the week, not like a clinical report. Avoid raw '
      'scores such as 7.0 or 4.0 in the response. Use natural language like '
      'higher stress, lower sleep, steadier energy, or more withdrawn days '
      'instead. Each JSON field must add a different insight and must not '
      'reuse the same sentence in multiple keys. Do not echo field labels '
      'such as positive symptoms, negative symptoms, sleep, stress, social '
      'energy, or Note. Prefer short compassionate paragraphs over bullets. Return '
      'exactly one valid JSON object and do not call tools, use function-call '
      'syntax, or wrap the JSON in markdown or extra text.';

  @override
  Future<WeeklyInsightsModel> fetchInsights(List<JournalEntry> entries) async {
    if (entries.isEmpty) {
      throw const ServerFailure(
        'No journal entries found for the past week. Please log at least one '
        'entry before generating insights.',
      );
    }

    await modelSetupService.ensureModelReady();

    InferenceModel? model;
    try {
      model = await FlutterGemma.getActiveModel(
        maxTokens: AppConstants.gemmaInsightsMaxTokens,
        preferredBackend: PreferredBackend.cpu,
      );

      final chat = await model.createChat(
        temperature: 0.2,
        modelType: ModelType.qwen3,
        supportsFunctionCalls: false,
        toolChoice: ToolChoice.none,
        systemInstruction: _systemInstruction,
      );

      await chat.addQueryChunk(
        Message.text(
          text: WeeklyInsightsModel.buildPrompt(entries),
          isUser: true,
        ),
      );

      final response = await chat.generateChatResponse();
      final rawResponse = _responseText(response);
      WeeklyInsightsModel draft;
      try {
        draft = WeeklyInsightsModel.fromRawResponse(rawResponse);
      } on FormatException {
        draft = const WeeklyInsightsModel.empty();
      }
      return WeeklyInsightsRefiner.refine(draft: draft, entries: entries);
    } catch (error) {
      if (error is Failure) {
        rethrow;
      }
      throw ServerFailure(
        'Could not generate offline insights with the on-device Gemma model: '
        '$error',
      );
    } finally {
      await model?.close();
    }
  }

  String _responseText(ModelResponse response) {
    return switch (response) {
      TextResponse(token: final token) => token,
      ThinkingResponse(content: final content) => content,
      FunctionCallResponse() => throw const ParseFailure(
          'The local Gemma model returned a tool call instead of text.',
        ),
      ParallelFunctionCallResponse() => throw const ParseFailure(
          'The local Gemma model returned multiple tool calls instead of text.',
        ),
    };
  }
}
