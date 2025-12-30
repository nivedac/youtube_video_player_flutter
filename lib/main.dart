import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player',
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
  // Test video URL provided by user
  final String videoUrl =
      'https://phplaravel-1505866-6013661.cloudwaysapps.com/videos/intro/intro.mp4';

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  /// Initialize the video player controller with the network video URL
  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );

    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: ${e.toString()}';
      });
    }
  }

  /// Listener to track playback state changes
  void _videoListener() {
    if (!mounted) return;
    setState(() {
      _isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  /// Toggle play/pause state
  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  /// Seek backward by 10 seconds
  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  /// Seek forward by 10 seconds
  void _seekForward() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(
      newPosition > duration ? duration : newPosition,
    );
  }

  /// Format duration to mm:ss format
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Video player area
              if (_hasError)
                _buildErrorWidget()
              else if (!_isInitialized)
                _buildLoadingWidget()
              else
                _buildVideoPlayer(),

              const SizedBox(height: 20),

              // Video progress slider
              if (_isInitialized && !_hasError) _buildProgressSlider(),

              const SizedBox(height: 20),

              // Playback controls
              if (_isInitialized && !_hasError) _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading indicator while video initializes
  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading video...'),
          ],
        ),
      ),
    );
  }

  /// Build error widget when video fails to load
  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializeVideoPlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the video player widget
  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            // Tap to toggle play/pause overlay
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: !_isPlaying ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build progress slider with time labels
  Widget _buildProgressSlider() {
    return Column(
      children: [
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.deepPurple,
            inactiveTrackColor: Colors.deepPurple.shade100,
            thumbColor: Colors.deepPurple,
            overlayColor: Colors.deepPurple.withAlpha(51),
          ),
          child: Slider(
            value: _controller.value.position.inSeconds.toDouble(),
            min: 0,
            max: _controller.value.duration.inSeconds.toDouble(),
            onChanged: (value) {
              _controller.seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build playback control buttons
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Seek backward button
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.replay_10),
          onPressed: _seekBackward,
          tooltip: 'Rewind 10 seconds',
        ),
        const SizedBox(width: 20),
        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withAlpha(77),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            iconSize: 48,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
            tooltip: _isPlaying ? 'Pause' : 'Play',
          ),
        ),
        const SizedBox(width: 20),
        // Seek forward button
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.forward_10),
          onPressed: _seekForward,
          tooltip: 'Forward 10 seconds',
        ),
      ],
    );
  }
}
