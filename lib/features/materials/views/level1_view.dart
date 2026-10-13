import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/materials/widgets/level1_view_body.dart';
import 'package:flutter/material.dart';

class Level1View extends StatelessWidget {
  const Level1View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Level 1',
        subtitle: '${level1Topics.length} topics · Intermediate track',
      ),
      body: const Level1ViewBody(),
    );
  }
}
