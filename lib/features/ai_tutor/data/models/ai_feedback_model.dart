import 'dart:convert';

class AiFeedbackModel {
  const AiFeedbackModel({
    required this.isCorrect,
    required this.feedback,
    this.hint = '',
    this.solution = '',
  });

  final bool isCorrect;

    final String feedback;

    final String hint;

    final String solution;

  bool get hasHint => hint.trim().isNotEmpty;
  bool get hasSolution => solution.trim().isNotEmpty;

      factory AiFeedbackModel.fromRawResponse(String raw) {
    final json = _extractJson(raw);
    if (json == null) {
                  return AiFeedbackModel(isCorrect: false, feedback: raw.trim());
    }

    String read(String key) {
      final value = json[key];
      if (value == null) return '';
      return value.toString().trim();
    }

    final verdict = read('verdict').toLowerCase();
    return AiFeedbackModel(
      isCorrect: verdict == 'correct' || verdict == 'true' || verdict == 'yes',
      feedback: read('feedback'),
      hint: read('hint'),
      solution: read('solution'),
    );
  }

  static Map<String, dynamic>? _extractJson(String raw) {
    var text = raw.trim();

        final fence = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$');
    final fenceMatch = fence.firstMatch(text);
    if (fenceMatch != null) text = fenceMatch.group(1)!.trim();

    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) return null;

    try {
      final decoded = jsonDecode(text.substring(start, end + 1));
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }
}
