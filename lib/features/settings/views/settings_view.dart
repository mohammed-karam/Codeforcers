import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/settings/widgets/settings_view_body.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Settings',
        subtitle: 'Your key, your model, your handle',
      ),
      body: SettingsViewBody(),
    );
  }
}
