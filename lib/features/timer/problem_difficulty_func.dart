import 'package:flutter/material.dart';

class ProblemDifficultyFunc extends StatelessWidget {
  const ProblemDifficultyFunc({
    super.key,
    required this.userRating,
    required this.problemRating,
  });

  final int userRating;
  final int problemRating;

  int calculateDifficulty() {
    final difference = problemRating - userRating;

    if (difference <= -200) {
      return 1;
    } else if (difference >= -199 && difference <= 100) {
      return 2;     } else if (difference >= 101 && difference <= 300) {
      return 3;     } else if (difference >= 301 && difference <= 500) {
      return 4;     } else {
      return 5;     }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Color(
            int.parse('0xFF${difficultyMap[calculateDifficulty()]![1]}'),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          difficultyMap[calculateDifficulty()]![0],
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

Map<int, List<String>> difficultyMap = {
    1: ['Easy', '008000'],
  2: ['Comfortable', '0000FF'],
  3: ['Challenging', 'FFFF00'],
  4: ['Hard', 'FFA500'],
  5: ['Very Hard', 'FF0000'],
};
