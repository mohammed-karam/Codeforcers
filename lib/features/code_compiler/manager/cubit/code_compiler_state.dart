part of 'code_compiler_cubit.dart';

sealed class CodeCompilerState {}

final class CodeCompilerInitial extends CodeCompilerState {}

final class CodeCompilerLoading extends CodeCompilerState {}

final class CodeCompilerSuccess extends CodeCompilerState {
  final CodeExecutionResultModel result;

  CodeCompilerSuccess({required this.result});
}

final class CodeCompilerFailure extends CodeCompilerState {
  final String errorMessage;

  CodeCompilerFailure({required this.errorMessage});
}
