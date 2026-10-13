import 'package:codeforcers/core/storage/solved_store.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/views/problem_workspace_view.dart';
import 'package:codeforcers/features/problems/views/problems_view.dart';
import 'package:flutter/material.dart';

class SolvedProblemsBody extends StatelessWidget {
  const SolvedProblemsBody({super.key});

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatDate(int millis) {
    if (millis <= 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static ProblemRef? toProblemRef(SolvedProblem solved) {
    final match = RegExp(r'^(\d+)(\D.*)$').firstMatch(solved.id);
    if (match == null) return null;

    return ProblemRef(
      contestId: int.parse(match.group(1)!),
      index: match.group(2)!,
      name: solved.name,
      rating: solved.rating,
      tags: solved.tags,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SolvedStore.instance.revision,
      builder: (context, revision, child) {
        final solved = SolvedStore.instance.all;

        if (solved.isEmpty) {
          return _emptyState(context);
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          itemCount: solved.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${solved.length} solved',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return _SolvedCard(solved: solved[index - 1]);
          },
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 34,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nothing solved yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Open a problem and tap the check mark when you solve it — it '
              'will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProblemsView()),
              ),
              icon: const Icon(Icons.list_alt_rounded, size: 17),
              label: const Text(
                'Open the problem list',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolvedCard extends StatelessWidget {
  const _SolvedCard({required this.solved});

  final SolvedProblem solved;

  @override
  Widget build(BuildContext context) {
    final band =
        solved.rating == null ? null : ratingBandOf(solved.rating);
    final badgeColor = band?.color ?? AppColors.textSecondary;
    final date = SolvedProblemsBody.formatDate(solved.solvedAt);

    return ScaleTap(
      semanticsLabel: solved.name,
      onTap: () {
        final problem = SolvedProblemsBody.toProblemRef(solved);
        if (problem == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProblemWorkspaceView(problem: problem),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                solved.rating?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solved.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.isEmpty
                        ? 'Solved'
                        : 'Solved on $date',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Remove from solved',
              onPressed: () => SolvedStore.instance.unmark(solved.id),
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
