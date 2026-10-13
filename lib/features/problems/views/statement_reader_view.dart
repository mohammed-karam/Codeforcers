import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/problems/data/models/statement_model.dart';
import 'package:codeforcers/features/problems/widgets/statement_body.dart';
import 'package:flutter/material.dart';

class StatementReaderView extends StatelessWidget {
  const StatementReaderView({
    super.key,
    required this.title,
    required this.statement,
  });

  final String title;
  final ProblemStatement statement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: title, subtitle: 'Statement'),
      body: SingleChildScrollView(
        child: StatementBody(statement: statement),
      ),
    );
  }
}
