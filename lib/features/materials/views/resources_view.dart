import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/materials/widgets/resources_view_body.dart';
import 'package:flutter/material.dart';

class ResourcesView extends StatelessWidget {
  const ResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Resources', subtitle: 'Your study curriculum'),
      body: ResourcesViewBody(),
    );
  }
}
