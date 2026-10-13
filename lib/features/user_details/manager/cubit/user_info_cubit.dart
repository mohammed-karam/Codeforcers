import 'package:bloc/bloc.dart';
import 'package:codeforcers/features/user_details/data/models/user_model.dart';
import 'package:codeforcers/features/user_details/data/repo/user_info_repo.dart';

part 'user_info_state.dart';

class UserInfoCubit extends Cubit<UserInfoState> {
  UserInfoCubit( this.userInfoRepo) : super(UserInfoInitial());

  final UserInfoRepo userInfoRepo;

  Future<void> fetchUserInfo(String handle) async {
    emit(UserInfoLoading());
    final result = await userInfoRepo.getUserInfo(handle);
    result.fold((failure){
      emit (UserInfoFailure(errorMessage: failure.errorMessage));
    } , (userModel) {
      emit(UserInfoSuccess(userModel: userModel));
    });
  }
}
