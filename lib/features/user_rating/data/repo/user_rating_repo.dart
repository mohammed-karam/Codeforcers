import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/user_rating/data/models/user_rating_model.dart';

abstract class UserRatingRepo {
  Future<Either<Failure, List<UserRatingModel>>> getUserRating(String handle);
}
