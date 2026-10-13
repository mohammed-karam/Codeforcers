import 'package:bloc/bloc.dart';
import 'package:codeforcers/features/user_rating/data/models/user_rating_model.dart';
import 'package:codeforcers/features/user_rating/data/repo/user_rating_repo.dart';

part 'user_rating_state.dart';

class UserRatingCubit extends Cubit<UserRatingState> {
  UserRatingCubit(this.userRatingRepo) : super(UserRatingInitial());

  final UserRatingRepo userRatingRepo;

  Future<void> fetchUserRating(String handle) async {
    emit(UserRatingLoading());
    final result = await userRatingRepo.getUserRating(handle);
    result.fold(
      (failure) => emit(UserRatingFailure(errorMessage: failure.errorMessage)),
      (ratings) => emit(UserRatingSuccess(ratings: ratings)),
    );
  }
}
