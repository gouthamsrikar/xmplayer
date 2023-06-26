import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';

class VideoView extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;
  const VideoView(this.controller, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: width,

      // width: width,
      child: controller.value.isInitialized
          ? AspectRatio(
              // aspectRatio: 16 / 9,
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(
                controller,
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}
