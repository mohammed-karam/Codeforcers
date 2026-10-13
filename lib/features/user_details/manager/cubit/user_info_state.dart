part of 'user_info_cubit.dart';

sealed class UserInfoState {}

final class UserInfoInitial extends UserInfoState {}

final class UserInfoLoading extends UserInfoState {}

final class UserInfoSuccess extends UserInfoState {
  final UserModel userModel;

  UserInfoSuccess({required this.userModel});
}

final class UserInfoFailure extends UserInfoState {
  final String errorMessage;

  UserInfoFailure({required this.errorMessage});
}
