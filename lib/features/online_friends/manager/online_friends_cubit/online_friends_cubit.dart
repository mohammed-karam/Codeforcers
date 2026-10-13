import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/online_friends/data/models/friend_info.dart';
import 'package:codeforcers/features/online_friends/data/models/online_friends_model.dart';
import 'package:codeforcers/features/online_friends/data/repo/online_friends_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'online_friends_state.dart';

class OnlineFriendsCubit extends Cubit<OnlineFriendsState> {
  OnlineFriendsCubit(this.onlineFriendsRepo) : super(OnlineFriendsInitial());

  final OnlineFriendsRepo onlineFriendsRepo;

              Future<void> getOnlineFriends() async {
    emit(OnlineFriendsLoading());

    final friendsOrFailure = await onlineFriendsRepo.getOnlineFriends();
    if (isClosed) return;

    final failure = friendsOrFailure.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) {
      emit(OnlineFriendsFailure(errorMessage: failure.errorMessage));
      return;
    }

    final model = friendsOrFailure.fold<OnlineFriendsModel?>((_) => null, (model) => model);
    if (model == null) return;

    emit(OnlineFriendsSuccess(onlineFriendsModel: model));

    final infoOrFailure = await onlineFriendsRepo.getFriendsInfo(model.result);
    if (isClosed) return;

    final info = infoOrFailure.fold<Map<String, FriendInfo>>(
      (_) => const <String, FriendInfo>{},
      (info) => info,
    );
    emit(OnlineFriendsSuccess(onlineFriendsModel: model, friendInfo: info));
  }
}
