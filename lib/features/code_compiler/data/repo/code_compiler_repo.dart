import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/code_compiler/data/models/code_execution_result_model.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';

abstract class CodeCompilerRepo {
  Future<Either<Failure, CodeExecutionResultModel>> runCode({
    required String code,
    required String stdin,
    required LanguageModel language,
  });
}
