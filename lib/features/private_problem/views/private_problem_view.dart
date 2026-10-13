import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/code_compiler/data/repo/code_compiler_repo_impl.dart';
import 'package:codeforcers/features/code_compiler/manager/cubit/code_compiler_cubit.dart';
import 'package:codeforcers/features/code_compiler/widgets/code_compiler_view_body.dart';
import 'package:codeforcers/features/private_problem/widgets/private_problem_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivateProblemView extends StatelessWidget {
  const PrivateProblemView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CodeCompilerCubit(
        CodeCompilerRepoImpl(apiService: Api()),
      ),
      child: CodeCompilerViewBody(
        appBar: const CustomAppBar(
          title: 'Private problem',
          subtitle: 'Browse it, then code right below',
        ),
                        editorFlex: 100,
        header: const PrivateProblemBody(),
      ),
    );
  }
}
