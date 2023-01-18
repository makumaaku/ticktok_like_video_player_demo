import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    Key? key,
    required this.videoPlayerController,
    required this.index,
  }) : super(key: key);

  final VideoPlayerController videoPlayerController;
  final int index;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.index.toString()),
      onVisibilityChanged: (info) {
        final visiblePercentage = info.visibleFraction * 100;
        if (visiblePercentage == 0) {
          widget.videoPlayerController.pause();
        } else if (visiblePercentage == 100) {
          widget.videoPlayerController.play();
        }
      },
      child: GestureDetector(
        onDoubleTap: () {
          // like
        },
        onTap: () {
          widget.videoPlayerController.value.isPlaying
              ? widget.videoPlayerController.pause()
              : widget.videoPlayerController.play();
        },
        child: AspectRatio(
          aspectRatio: widget.videoPlayerController.value.aspectRatio,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
                height: widget.videoPlayerController.value.size.height,
                width: widget.videoPlayerController.value.size.width,
                child: VideoPlayer(widget.videoPlayerController)),
          ),
        ),
      ),
    );
  }
}
