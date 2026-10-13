part of 'problems_list_cubit.dart';

sealed class ProblemsListState {
  const ProblemsListState();
}

final class ProblemsListLoading extends ProblemsListState {}

final class ProblemsListSuccess extends ProblemsListState {
  const ProblemsListSuccess({required this.problems});

  final List<ProblemRef> problems;
}

final class ProblemsListFailure extends ProblemsListState {
  const ProblemsListFailure({
    required this.errorMessage,
    this.problems = const <ProblemRef>[],
  });

  final String errorMessage;

    final List<ProblemRef> problems;
}
