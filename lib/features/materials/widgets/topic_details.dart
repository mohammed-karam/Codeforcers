import 'package:codeforcers/core/data.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/materials/widgets/video_player.dart';
import 'package:flutter/material.dart';

class TopicDetails extends StatelessWidget {
  const TopicDetails({
    super.key,
    required this.topicIndex,
    required this.topicTitle,
    required this.level,
  });

  final String topicTitle;
  final int topicIndex, level;

  @override
  Widget build(BuildContext context) {
    final topic = level == 0
        ? level0Topics[topicIndex]
        : level1Topics[topicIndex];
    final entries = topic.links.entries
        .where((entry) => entry.value != null && entry.value!.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: topicTitle,
        subtitle: 'Level $level · ${entries.length} videos',
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'No videos added for this topic yet.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final url = entry.value!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScaleTap(
                    semanticsLabel: _formatTerm(entry.key),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayer(videoUrl: url),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
                        children: [
                          _Thumbnail(url: url),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatTerm(entry.key),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.play_circle_fill_rounded,
                                      size: 15,
                                      color: AppColors.accentBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Watch now · ${topic.topicName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final thumbnail = getThumbnail(url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 116,
        height: 70,
        child: thumbnail == null
            ? const ColoredBox(
                color: AppColors.chipBackground,
                child: Icon(
                  Icons.movie_rounded,
                  color: AppColors.textSecondary,
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                          color: AppColors.chipBackground,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  ),
                  Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

String _formatTerm(String key) {
  final parts = key.split('_');
  if (parts.length == 1) return key;

  const months = {
    'winter': 'Winter',
    'spring': 'Spring',
    'summer': 'Summer',
    'fall': 'Fall',
    'autumn': 'Fall',
  };
  final name = months[parts.first] ?? parts.first;
  return '$name ${parts[1]}';
}

String? getThumbnail(String link) {
  final videoId = Uri.parse(link).queryParameters['v'];
  if (videoId == null || videoId.isEmpty) return null;

  return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
}
