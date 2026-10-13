import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/online_friends/data/models/friend_info.dart';
import 'package:codeforcers/features/online_friends/data/models/online_friends_model.dart';

abstract class OnlineFriendsRepo {
    Future<Either<Failure, OnlineFriendsModel>> getOnlineFriends();

            Future<Either<Failure, Map<String, FriendInfo>>> getFriendsInfo(
    List<String> handles,
  );
}
