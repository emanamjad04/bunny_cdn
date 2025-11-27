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
      allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;" 
        allowfullscreen="true"
        loading="lazy"
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

// String htmlPlayer(String hlsUrl) {
//   return '''
//     <!DOCTYPE html>
//     <html>
//       <head>
//         <meta name="viewport" content="width=device-width, initial-scale=1.0">
//         <style>
//           body, html { margin: 0; padding: 0; background: #000; height: 100%; }
//           video { width: 100%; height: 100%; background: #000; }
//           #pipBtn {
//             position: absolute; bottom: 20px; right: 20px;
//             padding: 10px 18px; background: rgba(255,255,255,0.8);
//             border: none; border-radius: 6px; font-size: 14px;
//           }
//         </style>
//       </head>
//       <body>
//         <video id="video" controls playsinline>
//           <source src="$hlsUrl" type="application/x-mpegURL">
//         </video>
//
//         <button id="pipBtn">PiP</button>
//
//         <script>
//           const video = document.getElementById('video');
//           const btn = document.getElementById('pipBtn');
//
//           btn.addEventListener('click', async () => {
//             try {
//               if (document.pictureInPictureElement) {
//                 await document.exitPictureInPicture();
//               } else {
//                 await video.requestPictureInPicture();
//               }
//             } catch (e) {
//               console.log("PiP not supported:", e);
//             }
//           });
//         </script>
//       </body>
//     </html>
//   ''';
// }

class BunnyPlayerWebView extends StatefulWidget {
  // final String videoUrl;
  const BunnyPlayerWebView({
    super.key,
    // required this.videoUrl
  });

  @override
  State<BunnyPlayerWebView> createState() => _BunnyPlayerWebViewState();
}

class _BunnyPlayerWebViewState extends State<BunnyPlayerWebView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>webView()));
              }, child: Text("webViewIframe")),
              ElevatedButton(onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BunnyBetterPlayer()));
              }, child: Text("betterPlayer")),
            ],
          ),
        ),
        // child: WebViewWidget(controller: _controller),
        // child: BunnyBetterPlayer(),
      ),
    );
  }
}
class webView extends StatefulWidget {
  const webView({super.key});

  @override
  State<webView> createState() => _webViewState();
}
class _webViewState extends State<webView> {


  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    //i am doing this for direct video playing
    // _controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadHtmlString(htmlPlayer("https://vz-5e491292-574.b-cdn.net/3d5a3ca0-fed6-455c-91e0-678f7381c497/playlist.m3u8"));

    _controller = WebViewController().s
      ..addJavaScriptChannel(
        'PlayerEvents',
        onMessageReceived: (JavaScriptMessage message) {
          print("Event from player seee: ${message.message}");
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..loadHtmlString(bunnyEmbedHtml(
          "https://iframe.mediadelivery.net/embed/284873/3d5a3ca0-fed6-455c-91e0-678f7381c497"
              "?autoplay=true"
              "&muted=true"
              "&loop=false"
              "&preload=true"
              "&responsive=true"
              "&showControls=true"
              "&showSpeed=true"
              "&skipSeconds=10"
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("webViewIframe"),
      ),
      body: WebViewWidget(controller: _controller),
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
  final GlobalKey _betterPlayerKey = GlobalKey();
  final ValueNotifier<bool> _showPiPButton = ValueNotifier(false);


  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://vz-5e491292-574.b-cdn.net/0a769661-fadd-4e14-be55-f864dc1eb934/playlist.m3u8",
      videoFormat: BetterPlayerVideoFormat.hls,

      // subtitles: BetterPlayerSubtitlesSource.single(
      //   type: BetterPlayerSubtitlesSourceType.network,
      //   url: "https://vz-5e491292-574.b-cdn.net/3d5a3ca0-fed6-455c-91e0-678f7381c497/subtitle.vtt",
      // ),
      useAsmsSubtitles: true,
      useAsmsTracks: true,
    );

    _betterPlayerController = BetterPlayerController(

      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        handleLifecycle: true,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePlaybackSpeed: true,
          enableSubtitles: true,
          enableSkips: true,
          enablePip: true,
          pipMenuIcon: Icons.picture_in_picture_alt,
          backgroundColor: Colors.white
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
    else if (event.betterPlayerEventType == BetterPlayerEventType.controlsVisible) {
      _showPiPButton.value = true;
    } else if (event.betterPlayerEventType == BetterPlayerEventType.controlsHiddenStart) {
      _showPiPButton.value = false;
    }
  }
  void _enterPip() async {
    try {
      // Many versions of better_player provide this API:
      await _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    } catch (e) {
      debugPrint("PiP not supported / failed: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BetterPlayer'),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: _betterPlayerController,key: _betterPlayerKey,),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _showPiPButton,
              builder: (context, visible, _) {
                return visible
                    ? Positioned(
                  bottom: 21,
                  right: 90,
                  child: IconButton(
                    onPressed: _enterPip,
                    icon: Icon(Icons.picture_in_picture_alt, color: Colors.white),
                  ),
                )
                    : const SizedBox();
              },
            ),

          ],
        )
      ),
    );
  }
}
