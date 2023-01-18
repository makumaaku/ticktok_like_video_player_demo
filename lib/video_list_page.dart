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

final initializedIndexProvider = StateProvider<List<int>>((ref) => []);

class _VideoListPageState extends ConsumerState<VideoListPage> {
  late PageController pageController;
  Map<int, VideoPlayerController> controllerMap = {};

  @override
  void initState() {
    super.initState();
    loadInitialVideo();
    // 連続スワイプするとpageが整数にならない場合あり。
    pageController = PageController();
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
        ref.read(initializedIndexProvider.notifier).state = [
          ...ref.read(initializedIndexProvider),
          i
        ];
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
    print('initializedIndexes: $initializedIndexes');
    return Scaffold(
      body: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          itemCount: videoUrls.length,
          onPageChanged: (pageIndex) {
            print('onPageChanged:$pageIndex');
            final willLoadIndex = pageIndex + 1;
            if (controllerMap[willLoadIndex] != null) {
              return;
            }
            if (videoUrls.length <= willLoadIndex) {
              return;
            }
            final willLoadVideoUrl = videoUrls[willLoadIndex];
            final videoController =
                VideoPlayerController.network(willLoadVideoUrl);
            videoController.initialize().then((_) {
              ref.read(initializedIndexProvider.notifier).state = [
                ...ref.read(initializedIndexProvider),
                willLoadIndex
              ];
              videoController.setLooping(true);
              print('initialized: $willLoadIndex');
            });
            controllerMap[willLoadIndex] = videoController;
          },
          itemBuilder: (_, index) {
            if (!initializedIndexes.contains(index)) {
              return GestureDetector(
                  onTap: () {
                    setState(() {});
                  },
                  child: const Center(child: CircularProgressIndicator()));
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
