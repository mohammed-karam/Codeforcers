import 'package:bloc/bloc.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/core/utils/constants.dart';
import 'package:codeforcers/features/ai_tutor/data/models/ai_feedback_model.dart';
import 'package:codeforcers/features/ai_tutor/data/repo/ai_tutor_repo.dart';

part 'ai_tutor_state.dart';

class AiTutorCubit extends Cubit<AiTutorState> {
  AiTutorCubit(this.aiTutorRepo) : super(AiTutorInitial());

  final AiTutorRepo aiTutorRepo;

    int attemptsUsed = 0;

    bool get trialsEnded => attemptsUsed >= kMaxAnswerTrials;

  Future<void> checkAnswer({
    required String question,
    required String answer,
  }) async {
    if (trialsEnded || state is AiTutorLoading) return;

    emit(AiTutorLoading());

                final attempt = attemptsUsed + 1;
    try {
      final result = await aiTutorRepo.checkAnswer(
        question: question,
        answer: answer,
        attempt: attempt,
      );

      result.fold(
        (failure) => emit(
          AiTutorFailure(
            errorMessage: failure.errorMessage,
            needsApiKey: failure is MissingApiKeyFailure,
          ),
        ),
        (feedback) {
          attemptsUsed = feedback.isCorrect ? 0 : attempt;
          emit(
            AiTutorFeedback(
              feedback: feedback,
              attempt: attempt,
              attemptsUsed: attemptsUsed,
            ),
          );
        },
      );
    } catch (_) {
      emit(
        AiTutorFailure(
          errorMessage: 'Something went wrong while contacting the AI, '
              'please try again.',
        ),
      );
    }
  }

  void reset() {
    attemptsUsed = 0;
    emit(AiTutorInitial());
  }
}
