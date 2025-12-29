import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Video Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final String videoUrl =
      'https://www.youtube.com/watch?v=y8VRXmo0y50&t=402s';

  late YoutubePlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        startAt: 402,
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    if (!mounted) return;
    setState(() {
      isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _controller.value.isPlaying
        ? _controller.pause()
        : _controller.play();
  }

  void _seekBackward() {
    final current = _controller.value.position.inSeconds;
    final newTime = current - 10;
    _controller.seekTo(
      Duration(seconds: newTime < 0 ? 0 : newTime),
    );
  }

  void _seekForward() {
    final current = _controller.value.position.inSeconds;
    final duration = _controller.metadata.duration.inSeconds;
    final newTime = current + 10;
    _controller.seekTo(
      Duration(seconds: newTime > duration ? duration : newTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Video Player'),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.deepPurple,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.deepPurple,
                  handleColor: Colors.deepPurpleAccent,
                ),
              ),

              const SizedBox(height: 30),

              // CONTROLS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.replay_10),
                    onPressed: _seekBackward,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 60,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.forward_10),
                    onPressed: _seekForward,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
