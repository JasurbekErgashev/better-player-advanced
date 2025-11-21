import 'dart:io';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiveHlsStreamPage extends StatefulWidget {
  const LiveHlsStreamPage({super.key});

  @override
  State<LiveHlsStreamPage> createState() => _LiveHlsStreamPageState();
}

class _LiveHlsStreamPageState extends State<LiveHlsStreamPage> {
  late BetterPlayerController _betterPlayerController;
  final GlobalKey _betterPlayerKey = GlobalKey();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeLiveStream();
  }

  void _initializeLiveStream() {
    const String liveHlsUrl =
        'https://stream-akamai.castr.com/5b9352dbda7b8c769937e459/live_2361c920455111ea85db6911fe397b9e/index.fmp4.m3u8';

    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      liveHlsUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
      liveStream: true, // Mark as live stream
    );

    final BetterPlayerConfiguration configuration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: Platform.isIOS ? true : false, // Auto-play on iOS for live streams
      looping: false,
      allowedScreenSleep: false,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableQualities: true,
        enableSubtitles: false,
        enablePlaybackSpeed: true,
        enablePip: true,
        enableFullscreen: true,
        enableAudioTracks: false,
        overflowMenuCustomItems: [],
      ),
      deviceOrientationsAfterFullScreen: const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      fullScreenAspectRatio: 16 / 9,
    );

    _betterPlayerController = BetterPlayerController(configuration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _betterPlayerController.addEventsListener(_handlePlayerEvents);

    setState(() {
      _isLoading = false;
    });
  }

  void _handlePlayerEvents(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      debugPrint("Live Stream Player Initialized");
    } else if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      debugPrint("Live Stream Player Exception: ${event.parameters}");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pipStart) {
      debugPrint("PiP Started for Live Stream");
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pipStop) {
      debugPrint("PiP Stopped for Live Stream");
    }
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Live HLS Stream Player'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Live HLS stream player with Picture-in-Picture support. '
                'This example demonstrates live streaming configuration.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasError)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load live stream',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          _initializeLiveStream();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  key: _betterPlayerKey,
                  controller: _betterPlayerController,
                ),
              ),
            if (!_isLoading && !_hasError) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_in_picture),
                      label: const Text('Enable PiP'),
                      onPressed: () async {
                        final isSupported = await _betterPlayerController.isPictureInPictureSupported();
                        if (isSupported) {
                          _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Picture-in-Picture is not supported on this device'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_in_picture_alt),
                      label: const Text('Disable PiP'),
                      onPressed: () async {
                        await _betterPlayerController.disablePictureInPicture();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}
