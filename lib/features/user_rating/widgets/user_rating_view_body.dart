import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/user_details/widgets/get_rating_color.dart';
import 'package:codeforcers/features/user_rating/data/models/user_rating_model.dart';
import 'package:codeforcers/features/user_rating/manager/cubit/user_rating_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserRatingViewBody extends StatefulWidget {
  final String handle;

  const UserRatingViewBody({super.key, required this.handle});

  @override
  State<UserRatingViewBody> createState() => _UserRatingViewBodyState();
}

class _UserRatingViewBodyState extends State<UserRatingViewBody> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<UserRatingCubit>(context).fetchUserRating(widget.handle);
  }

  String _formatDate(int seconds) {
    if (seconds == 0) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: '${widget.handle} — Contest History',
        roundedBottom: false,
      ),
      body: BlocBuilder<UserRatingCubit, UserRatingState>(
        builder: (context, state) {
          if (state is UserRatingLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserRatingFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (state is UserRatingSuccess) {
            return _buildRatingList(state.ratings);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildRatingList(List<UserRatingModel> ratings) {
        final reversed = ratings.reversed.toList();

    return Column(
      children: [
        _buildSummaryHeader(ratings),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: reversed.length,
            itemBuilder: (context, index) {
              return _buildContestCard(reversed[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(List<UserRatingModel> ratings) {
    final currentRating = ratings.last.newRating;
    final maxRating = ratings.map((r) => r.newRating).reduce(
      (a, b) => a > b ? a : b,
    );
    final ratingColor = getRatingColor(currentRating, maxRating);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHeaderStat(
            label: 'Contests',
            value: '${ratings.length}',
            color: Colors.white,
          ),
          _buildHeaderStat(
            label: 'Current',
            value: '$currentRating',
            color: ratingColor,
          ),
          _buildHeaderStat(
            label: 'Max',
            value: '$maxRating',
            color: getRatingColor(maxRating, maxRating),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContestCard(UserRatingModel entry, int index) {
    final ratingColor = getRatingColor(entry.newRating, entry.newRating);
    final isPositive = entry.ratingChange >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changePrefix = isPositive ? '+' : '';

    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
                        Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1B3B6F).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3B6F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

                        Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.contestName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(entry.ratingUpdateTimeSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

                        Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.newRating}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ratingColor,
                  ),
                ),
                Text(
                  '$changePrefix${entry.ratingChange}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
