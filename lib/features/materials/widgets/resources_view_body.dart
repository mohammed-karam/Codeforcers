import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/ai_tutor/views/ai_tutor_view.dart';
import 'package:codeforcers/features/materials/views/level0_view.dart';
import 'package:codeforcers/features/materials/views/level1_view.dart';
import 'package:flutter/material.dart';

class ResourcesViewBody extends StatelessWidget {
  const ResourcesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Curriculum',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Two levels, one path — pick up exactly where you left off.',
            style: TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _LevelCard(
            title: 'LEVEL 0',
            tagline: 'Beginner track',
            description:
                'Data types, conditions, loops, arrays, strings, functions, math and recursion.',
            topicsCount: level0Topics.length,
            icon: Icons.school_rounded,
            gradient: AppColors.level0Gradient,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Level0View()),
              );
            },
          ),
          const SizedBox(height: 18),
          _LevelCard(
            title: 'LEVEL 1',
            tagline: 'Intermediate track',
            description:
                'STLs, frequency arrays, number theory, sliding window, binary search and bitmasks.',
            topicsCount: level1Topics.length,
            icon: Icons.trending_up_rounded,
            gradient: AppColors.level1Gradient,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Level1View()),
              );
            },
          ),
          const SizedBox(height: 22),
          const _AiTutorCard(),
          const SizedBox(height: 22),
          const _InfoBanner(),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.title,
    required this.tagline,
    required this.description,
    required this.topicsCount,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String tagline;
  final String description;
  final int topicsCount;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      semanticsLabel: title,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -40,
                child: _blob(size: 150, opacity: 0.07),
              ),
              Positioned(
                right: 52,
                bottom: -58,
                child: _blob(size: 120, opacity: 0.05),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$topicsCount topics',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Open level',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _AiTutorCard extends StatelessWidget {
  const _AiTutorCard();

  @override
  Widget build(BuildContext context) {
    const gradient = AppColors.aiTutorGradient;

    return ScaleTap(
      semanticsLabel: 'AI Answer Checker',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AiTutorView()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                left: -46,
                bottom: -62,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '3 trials',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'AI ANSWER CHECKER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submit an answer, get corrected',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The AI hints you through 3 trials, then reveals the '
                      'full solution.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Text(
                          'Open checker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.navy,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Every topic keeps the recorded sessions for Winter 2026, '
              'Spring 2026 and the 2025 runs — jump into any term.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
