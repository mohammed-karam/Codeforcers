import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/user_details/data/repo/user_info_repo_impl.dart';
import 'package:codeforcers/features/user_details/manager/cubit/user_info_cubit.dart';
import 'package:codeforcers/features/user_details/widgets/user_details_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsView extends StatelessWidget {
  const UserDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoCubit(UserInfoRepoImpl(apiService: Api())),
      child: UserDetailsViewBody(),
    );
  }
}
