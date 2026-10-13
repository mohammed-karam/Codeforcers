import 'package:codeforcers/core/storage/solved_store.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/features/problems/views/problems_view.dart';
import 'package:codeforcers/features/problems/views/solved_problems_view.dart';
import 'package:flutter/material.dart';

class SolvedProgressCard extends StatelessWidget {
  const SolvedProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SolvedStore.instance.revision,
      builder: (context, revision, child) {
        final store = SolvedStore.instance;
        final total = store.count;
        final counts = store.countByRating();

        var maxCount = 1;
        for (final count in counts.values) {
          if (count > maxCount) maxCount = count;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1B3B6F),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Problems solved',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final band in ratingBands)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          band.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                color: AppColors.chipBackground,
                              ),
                              FractionallySizedBox(
                                widthFactor: (counts[band.label] ?? 0) /
                                    maxCount,
                                child: Container(
                                  height: 8,
                                  color: band.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${counts[band.label] ?? 0}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: total == 0
                    ? OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProblemsView(),
                          ),
                        ),
                        icon: const Icon(Icons.list_alt_rounded, size: 17),
                        label: const Text(
                          'Open the problem list',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: const BorderSide(color: AppColors.navy),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SolvedProblemsView(),
                          ),
                        ),
                        icon: const Icon(Icons.chevron_right_rounded,
                            size: 18),
                        label: const Text(
                          'See everything you solved',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
