import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticktok_like_video_player_demo/video_player_widget.dart';
import 'package:ticktok_like_video_player_demo/video_urls.dart';
import 'package:video_player/video_player.dart';

class VideoListPage extends ConsumerStatefulWidget {
  const VideoListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends ConsumerState<VideoListPage> {
  late PageController pageController;
  Map<int, VideoPlayerController> controllerMap = {};

  final initializedIndexProvider = StateProvider<List<int>>((ref) => []);

  @override
  void initState() {
    super.initState();
    loadInitialVideo();
    pageController = PageController()
      ..addListener(() {
        final page = pageController.page ?? 0;
        final pageInt = page.floor();
        final isPageChanging = page != pageInt;
        if (isPageChanging) {
          return;
        }
        final nextPageIndex = pageInt + 1;
        if (videoUrls.length < nextPageIndex) {
          return;
        }
        if (controllerMap[nextPageIndex] != null) {
          return;
        }
        final willLoadVideoUrl = videoUrls[nextPageIndex];
        final videoController = VideoPlayerController.network(willLoadVideoUrl);
        videoController.initialize().then((_) {
          final currentState = ref.read(initializedIndexProvider);
          ref.read(initializedIndexProvider.notifier).state = currentState
            ..add(nextPageIndex);
          videoController.setLooping(true);
          print('initialized: $nextPageIndex');
        });
        controllerMap[nextPageIndex] = videoController;
      });
  }

  void loadInitialVideo() {
    const initialLoadCount = 2;
    for (var i = 0; i < initialLoadCount; i++) {
      if (videoUrls.length < i + 1) {
        break;
      }
      final videoUrl = videoUrls[i];
      VideoPlayerController controller =
          VideoPlayerController.network(videoUrl);
      controller.initialize().then((_) {
        ref.read(initializedIndexProvider.notifier).state =
            ref.read(initializedIndexProvider)..add(i);
        controller.setLooping(true);
        print('initialized: $i');
        if (i == 0) {
          controller.play();
        }
      });
      controllerMap[i] = controller;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    for (final controller in controllerMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initializedIndexes = ref.watch(initializedIndexProvider);
    return Scaffold(
      body: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          itemCount: videoUrls.length,
          itemBuilder: (_, index) {
            print('initializedIndexes:$initializedIndexes');
            if (!initializedIndexes.contains(index)) {
              return const Center(child: CircularProgressIndicator());
            }
            final controller = controllerMap[index]!;
            return VideoPlayerWidget(
              videoPlayerController: controller,
              index: index,
            );
          }),
    );
  }
}
