import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/user_rating/data/repo/user_rating_repo_impl.dart';
import 'package:codeforcers/features/user_rating/manager/cubit/user_rating_cubit.dart';
import 'package:codeforcers/features/user_rating/widgets/user_rating_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserRatingView extends StatelessWidget {
  final String handle;

  const UserRatingView({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserRatingCubit(UserRatingRepoImpl(apiService: Api())),
      child: UserRatingViewBody(handle: handle),
    );
  }
}
