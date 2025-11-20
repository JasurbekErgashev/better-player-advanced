import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class HlsPipTestPage extends StatefulWidget {
  const HlsPipTestPage({super.key});

  @override
  State<HlsPipTestPage> createState() => _HlsPipTestPageState();
}

class _HlsPipTestPageState extends State<HlsPipTestPage> {
  late BetterPlayerController _betterPlayerController;
  final GlobalKey _betterPlayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    const BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
    );

    const String hlsVideoUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      hlsVideoUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('HLS PiP Test Player')),
        body: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'HLS video player for testing Picture-in-Picture mode.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: _betterPlayerController, key: _betterPlayerKey),
            ),
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
        ),
      );
}
