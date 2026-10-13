import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/materials/widgets/topic_details.dart';
import 'package:flutter/material.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.title,
    required this.topicId,
    required this.level,
    required this.index,
  });

  final String title, topicId;
  final int level, index;

  @override
  Widget build(BuildContext context) {
    final topic = level == 0 ? level0Topics[index] : level1Topics[index];
    final videoCount = topic.links.values
        .where((link) => link != null && link.isNotEmpty)
        .length;
    final gradient = level == 0
        ? AppColors.level0Gradient
        : AppColors.level1Gradient;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ScaleTap(
        semanticsLabel: title,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicDetails(
                topicIndex: index,
                topicTitle: title,
                level: level,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1B3B6F),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$videoCount videos',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.chipBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
