import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/submit/manager/cubit/submit_cubit.dart';
import 'package:codeforcers/features/submit/widgets/submit_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubmitView extends StatelessWidget {
  const SubmitView({
    super.key,
    required this.problem,
    required this.code,
    required this.language,
  });

  final ProblemRef problem;

    final String code;

    final LanguageModel language;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubmitCubit(problemCode: problem.id),
      child: SubmitViewBody(
        problem: problem,
        code: code,
        language: language,
      ),
    );
  }
}
