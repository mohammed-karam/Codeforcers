import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/materials/widgets/level0_view_body.dart';
import 'package:flutter/material.dart';

class Level0View extends StatelessWidget {
  const Level0View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Level 0',
        subtitle: '${level0Topics.length} topics · Beginner track',
      ),
      body: const Level0ViewBody(),
    );
  }
}
