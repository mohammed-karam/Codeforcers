import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.gradient = AppColors.brandGradient,
    this.roundedBottom = true,
    this.titleColor = Colors.white,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Gradient gradient;
  final bool roundedBottom;
  final Color titleColor;

  static const double cornerRadius = 22;

  double get _toolbarHeight => kToolbarHeight + (subtitle == null ? 0 : 22);

  @override
  Size get preferredSize => Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget;

    if (subtitle == null) {
      titleWidget = Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: titleColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      );
    } else {
      titleWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor.withValues(alpha: 0.75),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return AppBar(
      title: titleWidget,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: titleColor,
      actionsIconTheme: IconThemeData(color: titleColor),
      toolbarHeight: _toolbarHeight,
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: ClipRRect(
        borderRadius: roundedBottom
            ? const BorderRadius.vertical(
                bottom: Radius.circular(cornerRadius),
              )
            : BorderRadius.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
