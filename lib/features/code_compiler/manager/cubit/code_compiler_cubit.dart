import 'package:bloc/bloc.dart';
import 'package:codeforcers/features/code_compiler/data/models/code_execution_result_model.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/code_compiler/data/repo/code_compiler_repo.dart';

part 'code_compiler_state.dart';

class CodeCompilerCubit extends Cubit<CodeCompilerState> {
  CodeCompilerCubit(this.codeCompilerRepo) : super(CodeCompilerInitial());

  final CodeCompilerRepo codeCompilerRepo;

  Future<void> runCode({
    required String code,
    required String stdin,
    required LanguageModel language,
  }) async {
    emit(CodeCompilerLoading());
    final result = await codeCompilerRepo.runCode(
      code: code,
      stdin: stdin,
      language: language,
    );
    result.fold(
      (failure) => emit(CodeCompilerFailure(errorMessage: failure.errorMessage)),
      (executionResult) => emit(CodeCompilerSuccess(result: executionResult)),
    );
  }
}
