part of 'online_friends_cubit.dart';

@immutable
sealed class OnlineFriendsState {}

final class OnlineFriendsInitial extends OnlineFriendsState {}

class OnlineFriendsLoading extends OnlineFriendsState {}

class OnlineFriendsSuccess extends OnlineFriendsState {
  OnlineFriendsSuccess({required this.onlineFriendsModel, this.friendInfo});

  final OnlineFriendsModel onlineFriendsModel;

          final Map<String, FriendInfo>? friendInfo;
}

class OnlineFriendsFailure extends OnlineFriendsState {
  OnlineFriendsFailure({required this.errorMessage});

  final String errorMessage;
}
