import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo_impl.dart';
import 'package:codeforcers/features/problems/manager/cubit/problems_list_cubit.dart';
import 'package:codeforcers/features/problems/widgets/problems_list_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProblemsView extends StatelessWidget {
  const ProblemsView({super.key, this.repo});

    final ProblemsRepo? repo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProblemsListCubit(repo ?? ProblemsRepoImpl())
        ..load(),
      child: const Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Problems',
          subtitle: 'Open one and solve it here',
        ),
        body: ProblemsListBody(),
      ),
    );
  }
}
