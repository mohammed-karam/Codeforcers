import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/problems/data/cache/problems_cache.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/data/models/statement_model.dart';
import 'package:codeforcers/features/problems/data/parsers/statement_parser.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo.dart';
import 'package:http/http.dart' as http;

class ProblemsRepoImpl implements ProblemsRepo {
  ProblemsRepoImpl({
    Api? apiService,
    http.Client? client,
    ProblemsCache? cache,
    StatementParser? parser,
  })  : _api = apiService ?? Api(),
        _client = client ?? http.Client(),
        _cache = cache ?? const ProblemsCache(),
        _parser = parser ?? const StatementParser();

  static const String _problemsetUrl =
      'https://codeforces.com/api/problemset.problems';

    static const String _userAgent =
      'fawateery/1.0 (+https://codeforces.com); student problem browser';

  final Api _api;
  final http.Client _client;
  final ProblemsCache _cache;
  final StatementParser _parser;

  @override
  Future<Either<Failure, List<ProblemRef>>> fetchProblems({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _readCachedProblems();
      if (cached != null) return Right(cached);
    }

    try {
      final data = await _api.get(url: _problemsetUrl, body: {});
      final problems = _parseProblemset(data);
      await _cache.writeProblems(problems);
      return Right(problems);
    } catch (error) {
            final cached = await _readCachedProblems();
      if (cached != null) return Right(cached);
      return Left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, ProblemStatement>> fetchStatement(
    ProblemRef problem,
  ) async {
    final cached = await _cache.readStatement(problem.id);
    if (cached != null && cached.isNotEmpty) {
      final parsed = _tryParse(cached);
      if (parsed != null) return Right(parsed);
    }

    try {
      final response = await _client.get(
        Uri.parse(problem.statementUrl),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure.fromResponse(response));
      }

      final statement = _parser.parse(response.body);
      await _cache.writeStatement(problem.id, response.body);
      return Right(statement);
    } on FormatException catch (error) {
      return Left(
        ServerFailure(
          errorMessage: error.message.isEmpty
              ? 'This problem statement could not be read.'
              : error.message,
        ),
      );
    } on ServerFailure catch (error) {
      return Left(error);
    } on Exception catch (error) {
      return Left(ServerFailure.fromException(error));
    }
  }

  
  Future<List<ProblemRef>?> _readCachedProblems() async {
    final cached = await _cache.readProblems();
    if (cached == null || cached.isEmpty) return null;

    final problems = <ProblemRef>[];
    for (final json in cached) {
      try {
        problems.add(ProblemRef.fromJson(json));
      } on FormatException {
        continue;
      }
    }
    return problems.isEmpty ? null : problems;
  }

  ProblemStatement? _tryParse(String html) {
    try {
      return _parser.parse(html);
    } on FormatException {
      return null;
    }
  }

  static List<ProblemRef> _parseProblemset(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response from Codeforces.');
    }
    if (data['status'] != 'OK') {
      throw ServerFailure(
        errorMessage: (data['comment'] ?? 'Codeforces rejected the request.')
            .toString(),
      );
    }

    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response from Codeforces.');
    }

    final rawProblems = result['problems'];
    if (rawProblems is! List) {
      throw const FormatException('Unexpected response from Codeforces.');
    }

    final problems = <ProblemRef>[];
    for (final raw in rawProblems) {
      if (raw is! Map<String, dynamic>) continue;
      try {
        problems.add(ProblemRef.fromJson(raw));
      } on FormatException {
        continue;
      }
    }
    return problems;
  }

  static Failure _toFailure(Object error) {
    if (error is ServerFailure) return error;
    if (error is Exception) return ServerFailure.fromException(error);
    return ServerFailure(errorMessage: 'Could not load the problem list.');
  }
}
