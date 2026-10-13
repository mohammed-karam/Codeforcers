import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/data/models/statement_model.dart';

abstract class ProblemsRepo {
      Future<Either<Failure, List<ProblemRef>>> fetchProblems({
    bool forceRefresh = false,
  });

    Future<Either<Failure, ProblemStatement>> fetchStatement(
    ProblemRef problem,
  );
}
