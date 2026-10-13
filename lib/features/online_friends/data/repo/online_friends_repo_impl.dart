import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/online_friends/data/models/friend_info.dart';
import 'package:codeforcers/features/online_friends/data/models/online_friends_model.dart';
import 'package:codeforcers/features/online_friends/data/repo/online_friends_repo.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/utils/constants.dart';
import 'package:codeforcers/core/utils/url_finder.dart';

class OnlineFriendsRepoImpl extends OnlineFriendsRepo {
  OnlineFriendsRepoImpl({required this.apiService});

  final Api apiService;

      static const int infoChunkSize = 100;

  @override
  Future<Either<Failure, OnlineFriendsModel>> getOnlineFriends() async {
    try {
      final url = generateCodeforcesUrl(
        methodName: 'user.friends',
        params: {'onlyOnline': 'true'},
        apiKey: userApiKey,
        apiSecret: userApiSecret,
      );
      final data = await apiService.get(url: url, body: {});
      return Right(OnlineFriendsModel.fromJson(data));
    } on ServerFailure catch (e) {
      return left(e);
    } on Exception catch (e) {
      return left(ServerFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, FriendInfo>>> getFriendsInfo(
    List<String> handles,
  ) async {
    if (handles.isEmpty) return const Right({});

            final requestedByKey = <String, String>{
      for (final handle in handles) handle.toLowerCase(): handle,
    };

    final info = <String, FriendInfo>{};
    Failure? failure;

    for (var start = 0; start < handles.length; start += infoChunkSize) {
      final rawEnd = start + infoChunkSize;
      final end = rawEnd < handles.length ? rawEnd : handles.length;
      final chunk = handles.sublist(start, end);
      final url =
          'https://codeforces.com/api/user.info?handles='
          '${chunk.map(Uri.encodeComponent).join(';')}';

      try {
        final data = await apiService.get(url: url, body: {});
        if (data is! Map<String, dynamic> ||
            data['status'] != 'OK' ||
            data['result'] is! List) {
          failure ??= ServerFailure(
            errorMessage: 'Codeforces did not return friend details.',
          );
          continue;
        }
        for (final entry in data['result'] as List<dynamic>) {
          if (entry is! Map<String, dynamic>) continue;
          final friend = FriendInfo.fromJson(entry);
          final key = requestedByKey[friend.handle.toLowerCase()];
          info[key ?? friend.handle] = friend;
        }
      } on ServerFailure catch (e) {
                failure ??= e;
      } on Exception catch (e) {
        failure ??= ServerFailure.fromException(e);
      }
    }

            if (info.isEmpty && failure != null) return Left(failure);
    return Right(info);
  }
}
