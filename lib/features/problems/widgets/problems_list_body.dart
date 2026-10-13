import 'package:codeforcers/core/storage/solved_store.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/private_problem/views/private_problem_view.dart';
import 'package:codeforcers/features/problems/manager/cubit/problems_list_cubit.dart';
import 'package:codeforcers/features/problems/views/problem_workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _error = Color(0xFFDC2626);

class ProblemsListBody extends StatefulWidget {
  const ProblemsListBody({super.key});

  @override
  State<ProblemsListBody> createState() => _ProblemsListBodyState();
}

class _ProblemsListBodyState extends State<ProblemsListBody> {
  String _query = '';
  String _status = 'all';
  RatingBand? _band;

  void _setQuery(String value) => setState(() => _query = value.trim());

  void _setStatus(String value) => setState(() => _status = value);

  void _setBand(RatingBand? value) => setState(() => _band = value);

  bool get _hasFilters => _query.isNotEmpty || _status != 'all' || _band != null;

  void _clearFilters() {
    setState(() {
      _query = '';
      _status = 'all';
      _band = null;
    });
  }

  List<ProblemRef> _applyFilters(List<ProblemRef> problems) {
    final query = _query.toLowerCase();

    final filtered = problems.where((problem) {
      if (query.isNotEmpty) {
        final matchesName = problem.name.toLowerCase().contains(query);
        final matchesCode = problem.id.toLowerCase().contains(query);
        if (!matchesName && !matchesCode) return false;
      }

      final solved = SolvedStore.instance.isSolved(problem.id);
      if (_status == 'solved' && !solved) return false;
      if (_status == 'unsolved' && solved) return false;

      final band = _band;
      if (band != null && !band.contains(problem.rating)) return false;

      return true;
    }).toList();

    filtered.sort((a, b) {
      final aRating = a.rating;
      final bRating = b.rating;
      if (aRating == null && bRating == null) {
        return a.name.compareTo(b.name);
      }
      if (aRating == null) return 1;
      if (bRating == null) return -1;
      final byRating = aRating.compareTo(bRating);
      return byRating != 0 ? byRating : a.name.compareTo(b.name);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: TextField(
            onChanged: _setQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name or id, e.g. 1850C',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => _setQuery(''),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: ScaleTap(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivateProblemView()),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.navy.withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                children: [
                  _GlobeBadge(),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Private problem, or not on Codeforces?',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Open it in the browser and code right below it',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChip(
                label: 'All',
                selected: _status == 'all',
                onTap: () => _setStatus('all'),
              ),
              _FilterChip(
                label: 'Unsolved',
                selected: _status == 'unsolved',
                onTap: () => _setStatus('unsolved'),
              ),
              _FilterChip(
                label: 'Solved',
                selected: _status == 'solved',
                onTap: () => _setStatus('solved'),
              ),
              const SizedBox(width: 6),
              Container(width: 1, height: 24, color: AppColors.border),
              const SizedBox(width: 6),
              for (final band in ratingBands)
                _FilterChip(
                  label: band.label,
                  selected: _band?.label == band.label,
                  onTap: () => _setBand(_band?.label == band.label ? null : band),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: BlocBuilder<ProblemsListCubit, ProblemsListState>(
            builder: (context, state) {
              if (state is ProblemsListLoading) {
                return const _LoadingState();
              }

              if (state is ProblemsListFailure && state.problems.isEmpty) {
                return _ErrorState(
                  message: state.errorMessage,
                  onRetry: () => context
                      .read<ProblemsListCubit>()
                      .load(forceRefresh: true),
                );
              }

              final problems = state is ProblemsListSuccess
                  ? state.problems
                  : state is ProblemsListFailure
                      ? state.problems
                      : const <ProblemRef>[];
              final visible = _applyFilters(problems);

              return RefreshIndicator(
                color: AppColors.navy,
                onRefresh: () => context
                    .read<ProblemsListCubit>()
                    .load(forceRefresh: true),
                child: visible.isEmpty
                    ? _EmptyState(
                        hasFilters: _hasFilters,
                        totalCount: problems.length,
                        onClearFilters: _clearFilters,
                        onRetry: () => context
                            .read<ProblemsListCubit>()
                            .load(forceRefresh: true),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _ProblemCard(problem: visible[index]),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.problem});

  final ProblemRef problem;

  @override
  Widget build(BuildContext context) {
    final solved = SolvedStore.instance.isSolved(problem.id);
    final rating = problem.rating;
    final badgeColor =
        rating == null ? AppColors.textSecondary : ratingBandOf(rating).color;

    return ScaleTap(
      semanticsLabel: problem.name,
      onTap: () {
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
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1B3B6F),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: solved
                    ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                    : badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rating?.toString() ?? '—',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: solved ? const Color(0xFF16A34A) : badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problem.name,
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
                    problem.tags.isEmpty
                        ? 'Problem ${problem.code}'
                        : '${problem.code} · ${problem.tags.take(3).join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              solved
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              size: solved ? 22 : 24,
              color: solved ? const Color(0xFF16A34A) : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


class _GlobeBadge extends StatelessWidget {
  const _GlobeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.language_rounded,
        size: 17,
        color: AppColors.navy,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.navy : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}


class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Downloading the problemset…',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _stateCard(
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 30, color: _error),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 17),
            label: const Text(
              'Try again',
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
          TextButton.icon(
            onPressed: openProblemsetInBrowser,
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: const Text(
              'Open on codeforces.com',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilters,
    required this.totalCount,
    required this.onClearFilters,
    required this.onRetry,
  });

  final bool hasFilters;
  final int totalCount;
  final VoidCallback onClearFilters;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isSearching = hasFilters;

    return _stateCard(
      child: Column(
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.inbox_rounded,
            size: 30,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            isSearching
                ? 'No problems match these filters.'
                : 'No problems loaded yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? '$totalCount problems are loaded — loosen the filters to see them.'
                : 'Pull to refresh, or open the list again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSearching)
                OutlinedButton(
                  onPressed: onClearFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text(
                    'Load problems',
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
        ],
      ),
    );
  }
}

Widget _stateCard({required Widget child}) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.fromBorderSide(BorderSide(color: AppColors.border)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> openProblemsetInBrowser() async {
  await launchUrl(
    Uri.parse('https://codeforces.com/problemset'),
    mode: LaunchMode.platformDefault,
  );
}
