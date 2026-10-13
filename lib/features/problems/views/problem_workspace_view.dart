import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/features/code_compiler/data/repo/code_compiler_repo_impl.dart';
import 'package:codeforcers/features/code_compiler/manager/cubit/code_compiler_cubit.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo_impl.dart';
import 'package:codeforcers/features/problems/manager/cubit/statement_cubit.dart';
import 'package:codeforcers/features/problems/widgets/problem_workspace_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProblemWorkspaceView extends StatelessWidget {
  const ProblemWorkspaceView({
    super.key,
    required this.problem,
    this.repo,
  });

  final ProblemRef problem;

    final ProblemsRepo? repo;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StatementCubit(repo ?? ProblemsRepoImpl())
            ..load(problem),
        ),
        BlocProvider(
          create: (context) => CodeCompilerCubit(
            CodeCompilerRepoImpl(apiService: Api()),
          ),
        ),
      ],
      child: ProblemWorkspaceBody(problem: problem),
    );
  }
}
