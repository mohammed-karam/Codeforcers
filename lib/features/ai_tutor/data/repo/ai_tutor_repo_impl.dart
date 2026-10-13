import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/utils/constants.dart';
import 'package:codeforcers/features/ai_tutor/data/models/ai_feedback_model.dart';
import 'package:codeforcers/features/ai_tutor/data/repo/ai_tutor_repo.dart';

class AiTutorRepoImpl extends AiTutorRepo {
  final Api apiService;

  AiTutorRepoImpl({required this.apiService});

  static const String _systemPrompt = '''
You are a strict but encouraging tutor. A student submits an answer to a question and you grade it.

You ALWAYS reply with a single JSON object and nothing else: no markdown, no code fences, no extra text.
The JSON object has exactly these keys:
{
  "verdict": "correct" or "incorrect",
  "feedback": "short explanation",
  "hint": "hint for the next attempt, or empty string",
  "solution": "full solution, or empty string"
}

Rules:
1. verdict: judge the student's answer only against the given question. Accept equivalent wording and any correct code that solves the problem. Ignore harmless typos and formatting.
2. feedback: 1 to 3 short sentences saying exactly what is right or wrong, written in the same language as the student's answer. Never reveal the full solution in the feedback.
3. hint: guidance for the next attempt, in the same language as the student's answer. Never give the final answer away. Escalate with the attempt number:
   - attempt 1: a gentle nudge in the right direction.
   - attempt 2: point at the relevant concept or step.
   - attempt 3: state clearly which step is wrong and how to fix it.
   When the answer is correct, set hint to "".
4. solution: always "" except on attempt 3 when the answer is incorrect. In that case write a complete step-by-step solution the student can learn from.
5. Keep feedback and hint under 60 words each. The solution may be longer.
''';

  @override
  Future<Either<Failure, AiFeedbackModel>> checkAnswer({
    required String question,
    required String answer,
    required int attempt,
  }) async {
            final settings = AppSettings.instance;
    if (!settings.hasGroqApiKey) {
      return Left(MissingApiKeyFailure());
    }

    try {
      final data = await apiService.post(
        url: groqChatCompletionsUrl,
        body: {
          'model': settings.groqModel,
          'temperature': 0.3,
          'max_tokens': 2000,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {
              'role': 'user',
              'content':
                  'Attempt: $attempt of $kMaxAnswerTrials\n\n'
                  'Question:\n$question\n\n'
                  "Student's answer:\n$answer",
            },
          ],
        },
        token: settings.groqApiKey,
                headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final content = _contentOf(data);
      if (content == null || content.isEmpty) {
        return Left(
          ServerFailure(
            errorMessage: 'The AI returned an empty response, please try again',
          ),
        );
      }

      return Right(AiFeedbackModel.fromRawResponse(content));
    } on ServerFailure catch (e) {
      return Left(e);
    } on Exception catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

    static String? _contentOf(dynamic data) {
    try {
      final choices = (data as Map<String, dynamic>)['choices'];
      if (choices is! List || choices.isEmpty) return null;

      final message = choices.first['message'];
      if (message is! Map) return null;

      final content = message['content'];
      if (content is! String) return null;
      return content;
    } catch (_) {
      return null;
    }
  }
}
