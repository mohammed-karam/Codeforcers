class CfSubmission {
  const CfSubmission({
    required this.id,
    required this.creationTimeSeconds,
    required this.verdict,
    required this.problemCode,
    required this.language,
    this.passedTests,
  });

    final int id;

    final int creationTimeSeconds;

    final String verdict;

      final String problemCode;

    final String language;

    final int? passedTests;

    bool get isJudging => verdict.isEmpty || verdict == 'TESTING';

  bool get isAccepted => verdict == 'OK';

      int get ageInSeconds =>
      DateTime.now().millisecondsSinceEpoch ~/ 1000 - creationTimeSeconds;

    bool get isRecent => ageInSeconds.abs() < 180;

      String get friendlyVerdict {
    if (isJudging) return 'Running…';

    final name = switch (verdict) {
      'OK' => 'Accepted',
      'PARTIAL' => 'Partial answer',
      'COMPILATION_ERROR' => 'Compilation error',
      'WRONG_ANSWER' => 'Wrong answer',
      'RUNTIME_ERROR' => 'Runtime error',
      'TIME_LIMIT_EXCEEDED' => 'Time limit exceeded',
      'MEMORY_LIMIT_EXCEEDED' => 'Memory limit exceeded',
      'IDLENESS_LIMIT_EXCEEDED' => 'Idleness limit exceeded',
      'SECURITY_VIOLATED' => 'Security violation',
      'CHALLENGED' => 'Hacked',
      'SKIPPED' => 'Skipped',
      'DENIED' => 'Denied',
      'CRASHED' => 'Crashed',
      _ => verdict.isEmpty ? 'Unknown' : verdict,
    };

                final counted = const <String>{
      'WRONG_ANSWER',
      'RUNTIME_ERROR',
      'TIME_LIMIT_EXCEEDED',
      'MEMORY_LIMIT_EXCEEDED',
      'IDLENESS_LIMIT_EXCEEDED',
      'CRASHED',
    };
    final passed = passedTests;
    if (passed != null && counted.contains(verdict)) {
      return '$name on test ${passed + 1}';
    }
    return name;
  }

    bool get looksGood => isAccepted;

  factory CfSubmission.fromApiJson(Map<String, dynamic> json) {
    final problem = json['problem'];
    var code = '';
    if (problem is Map<String, dynamic>) {
      final contestId = problem['contestId'];
      final index = problem['index'];
      if (contestId != null && index != null) code = '$contestId$index';
    }

    final passed = json['passedTests'];

    return CfSubmission(
      id: json['id'] is int ? json['id'] as int : 0,
      creationTimeSeconds:
          json['creationTimeSeconds'] is int ? json['creationTimeSeconds'] as int : 0,
      verdict: json['verdict']?.toString() ?? '',
      problemCode: code,
      language: json['programmingLanguage']?.toString() ?? '',
      passedTests: passed is int ? passed : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'creationTimeSeconds': creationTimeSeconds,
        'verdict': verdict,
        'problemCode': problemCode,
        'language': language,
        'passedTests': passedTests,
      };

  factory CfSubmission.fromJson(Map<String, dynamic> json) => CfSubmission(
        id: json['id'] as int? ?? 0,
        creationTimeSeconds: json['creationTimeSeconds'] as int? ?? 0,
        verdict: json['verdict'] as String? ?? '',
        problemCode: json['problemCode'] as String? ?? '',
        language: json['language'] as String? ?? '',
        passedTests: json['passedTests'] is int ? json['passedTests'] as int : null,
      );
}
