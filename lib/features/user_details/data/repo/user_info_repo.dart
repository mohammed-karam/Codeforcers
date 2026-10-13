
import 'package:dartz/dartz.dart';
import 'package:codeforcers/core/errors/failures.dart';
import 'package:codeforcers/features/user_details/data/models/user_model.dart';

abstract class UserInfoRepo {
  Future<Either<Failure, UserModel>> getUserInfo(String handle);
}