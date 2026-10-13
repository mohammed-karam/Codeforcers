import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/ai_tutor/data/models/ai_feedback_model.dart';

abstract class AiTutorRepo {
          Future<Either<Failure, AiFeedbackModel>> checkAnswer({
    required String question,
    required String answer,
    required int attempt,
  });
}
