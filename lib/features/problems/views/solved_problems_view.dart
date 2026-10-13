import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/problems/widgets/solved_problems_body.dart';
import 'package:flutter/material.dart';

class SolvedProblemsView extends StatelessWidget {
  const SolvedProblemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'What you solved',
        subtitle: 'Your progress on this device',
      ),
      body: SolvedProblemsBody(),
    );
  }
}
