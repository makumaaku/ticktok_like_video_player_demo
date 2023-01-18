import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticktok_like_video_player_demo/video_list_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Like Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoListPage(),
    );
  }
}
