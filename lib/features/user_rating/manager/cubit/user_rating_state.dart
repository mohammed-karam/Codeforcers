part of 'user_rating_cubit.dart';

sealed class UserRatingState {}

final class UserRatingInitial extends UserRatingState {}

final class UserRatingLoading extends UserRatingState {}

final class UserRatingSuccess extends UserRatingState {
  final List<UserRatingModel> ratings;

  UserRatingSuccess({required this.ratings});
}

final class UserRatingFailure extends UserRatingState {
  final String errorMessage;

  UserRatingFailure({required this.errorMessage});
}
