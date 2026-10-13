import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(title: 'Video Player'),
          body: Center(child: player),
        );
      },
    );
  }
}
