import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/utils/constants.dart';
import 'package:codeforcers/features/code_compiler/data/models/code_execution_result_model.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/code_compiler/data/repo/code_compiler_repo.dart';

class CodeCompilerRepoImpl extends CodeCompilerRepo {
  final Api apiService;

  CodeCompilerRepoImpl({
    required this.apiService,
  });

  static const String _onlineCompilerUrl = 'https://api.onlinecompiler.io/api/run-code-sync/';

  @override
  Future<Either<Failure, CodeExecutionResultModel>> runCode({
    required String code,
    required String stdin,
    required LanguageModel language,
  }) async {
    try {
      final body = {
        'compiler': language.compilerId,
        'code': code,
        'input': stdin,
      };

      final data = await apiService.post(
        url: _onlineCompilerUrl,
        body: body,
        token: null,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': onlineCompilerApiKey,
        },
      );

      return Right(
        CodeExecutionResultModel.fromJson(data as Map<String, dynamic>),
      );
    } on ServerFailure catch (e) {
      return Left(e);
    } on Exception catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
}
