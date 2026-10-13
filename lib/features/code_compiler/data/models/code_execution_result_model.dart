class CodeExecutionResultModel {
  final String outputText;
  final String errorText;
  final String status;
  final int exitCodeValue;

  CodeExecutionResultModel({
    required this.outputText,
    required this.errorText,
    required this.status,
    required this.exitCodeValue,
  });

  bool get hasError => status != 'success' || exitCodeValue != 0;

  String get stdout => outputText;
  String get stderr => errorText;
  int get exitCode => exitCodeValue;

  factory CodeExecutionResultModel.fromJson(Map<String, dynamic> json) {
    return CodeExecutionResultModel(
      outputText: json['output'] as String? ?? '',
      errorText: json['error'] as String? ?? '',
      status: json['status'] as String? ?? 'error',
      exitCodeValue: json['exit_code'] as int? ?? -1,
    );
  }
}
