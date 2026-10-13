part of 'statement_cubit.dart';

sealed class StatementState {
  const StatementState();
}

final class StatementLoading extends StatementState {}

final class StatementSuccess extends StatementState {
  const StatementSuccess({required this.statement});

  final ProblemStatement statement;
}

final class StatementFailure extends StatementState {
  const StatementFailure({required this.errorMessage});

  final String errorMessage;
}
