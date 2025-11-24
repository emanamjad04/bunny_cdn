import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: BunnyPlayerWebView(),
  ));
}


String bunnyEmbedHtml(String videoUrl) {
  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body, html { margin: 0; padding: 0; background-color: #000; height: 100%; }
      #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
    </style>
  </head>
  <body>
    <iframe
      id="player"
      src="$videoUrl"
      allow="autoplay; encrypted-media; picture-in-picture;"
      allowfullscreen
    ></iframe>

    <script>
      const iframe = document.getElementById('player').contentWindow;
      window.addEventListener("message", (event) => {
        if (event.data && event.data.event) {
          PlayerEvents.postMessage(event.data.event);
        }
      });
    </script>
  </body>
</html>
''';
}


class BunnyPlayerWebView extends StatefulWidget {
  // final String videoUrl;
  const BunnyPlayerWebView({super.key,
    // required this.videoUrl
  });

  @override
  State<BunnyPlayerWebView> createState() => _BunnyPlayerWebViewState();
}

class _BunnyPlayerWebViewState extends State<BunnyPlayerWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();


    _controller = WebViewController()
      ..addJavaScriptChannel('PlayerEvents',
        onMessageReceived: (JavaScriptMessage message) {
          print("Event from player seee: ${message.message}");
        },)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..loadHtmlString(bunnyEmbedHtml("https://iframe.mediadelivery.net/play/284873/3d5a3ca0-fed6-455c-91e0-678f7381c497"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
        // child: BunnyBetterPlayer(),
      ),
    );
  }
}

class BunnyBetterPlayer extends StatefulWidget {
  const BunnyBetterPlayer({super.key});

  @override
  State<BunnyBetterPlayer> createState() => _BunnyBetterPlayerState();
}

class _BunnyBetterPlayerState extends State<BunnyBetterPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://vz-5e491292-574.b-cdn.net/3d5a3ca0-fed6-455c-91e0-678f7381c497/playlist.m3u8",
      subtitles: BetterPlayerSubtitlesSource.single(
        type: BetterPlayerSubtitlesSourceType.network,
        url: "https://vz-5e491292-574.b-cdn.net/3d5a3ca0-fed6-455c-91e0-678f7381c497/subtitle.vtt",
      ),
      useAsmsSubtitles: true,
      useAsmsTracks: true,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlaybackSpeed: true,
          enableSubtitles: true,
          enableSkips: true,
        ),
        eventListener: _handleBetterPlayerEvent,
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  void _handleBetterPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      print("Current position: ${event.parameters!["progress"]}");
    } else if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      print("Video ended");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}