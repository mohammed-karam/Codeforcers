part of 'ai_tutor_cubit.dart';

sealed class AiTutorState {}

final class AiTutorInitial extends AiTutorState {}

final class AiTutorLoading extends AiTutorState {}

final class AiTutorFeedback extends AiTutorState {
  final AiFeedbackModel feedback;

    final int attempt;

    final int attemptsUsed;

  AiTutorFeedback({
    required this.feedback,
    required this.attempt,
    required this.attemptsUsed,
  });
}

final class AiTutorFailure extends AiTutorState {
  final String errorMessage;

      final bool needsApiKey;

  AiTutorFailure({required this.errorMessage, this.needsApiKey = false});
}
