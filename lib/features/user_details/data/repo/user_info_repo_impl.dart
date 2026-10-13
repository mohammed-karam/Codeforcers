import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/user_details/data/models/user_model.dart';
import 'package:codeforcers/features/user_details/data/repo/user_info_repo.dart';

class UserInfoRepoImpl extends UserInfoRepo {
  final Api apiService;

  UserInfoRepoImpl({required this.apiService});

  @override
  Future<Either<Failure, UserModel>> getUserInfo(String handle) async {
    try {
      final data = await apiService.get(
        url:
            'https://codeforces.com/api/user.info?handles=$handle&checkHistoricHandles=false',
        body: {},
      );
      return Right(UserModel.fromJson(data['result'][0]));
    } on ServerFailure catch (e) {
      return left(e);
    } on Exception catch (e) {
      return left(ServerFailure.fromException(e));
    }
  }
}
