import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class LiveHlsTestPage extends StatefulWidget {
  const LiveHlsTestPage({super.key});

  @override
  State<LiveHlsTestPage> createState() => _LiveHlsTestPageState();
}

class _LiveHlsTestPageState extends State<LiveHlsTestPage> {
  late BetterPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    const liveStreamUrl = 'https://cdn.jwplayer.com/live/events/gnQshxdK.m3u8?exp=1763995200&sig=b0d3accf5c452fa32b26ad6e54a3a0a0';
    
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      liveStreamUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
      liveStream: true,
    );

    final configuration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: false,
      looping: false,
      allowedScreenSleep: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableQualities: true,
        enableSubtitles: false,
        enablePlaybackSpeed: true,
        enablePip: true,
        enableFullscreen: true,
        enableAudioTracks: false,
      ),
    );

    _controller = BetterPlayerController(
      configuration,
      betterPlayerDataSource: dataSource,
    );

    _controller.addEventsListener(_handlePlayerEvents);
  }

  void _handlePlayerEvents(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() {
        _isPlaying = true;
      });
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live HLS Stream Test'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Test Live HLS Stream Resume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Instructions:\n1. Play the video\n2. Wait a few seconds\n3. Pause the video\n4. Resume playback\n5. The video should continue from where you paused or jump to the latest live position, NOT restart from the beginning.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(controller: _controller),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (_isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Pause' : 'Play'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

