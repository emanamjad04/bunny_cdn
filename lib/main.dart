import 'package:better_player_plus/better_player_plus.dart';
import 'package:bogo_sdk/bogo_sdk.dart';
import 'package:bunny_cdn/pipProvider.dart';
import 'package:bunny_cdn/zongapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  await BogoSDK.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>PipProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BunnyPlayerWebView(),
      ) ,
    )
     );
}
Future<void> requestPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.locationWhenInUse.request();
}
String bunnyEmbedHtmlold(String videoUrl) {
  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <style>
body, html { margin: 0; padding: 0; background-color: #000; height: 100%; }
#player { object-fit: cover; width: 100%; height: 100%; border: none; }
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

String bunnyEmbedHtml(String videoUrl) {
  // Use the full URL as the iframe src
  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body, html { margin: 0; padding: 0; background-color: #000; height: 100%; }
      #bunny-video-player { object-fit: cover; width: 100%; height: auto; aspect-ratio:16/9; border: none; }
    </style>
  </head>
  <body>
    <iframe
      id="bunny-video-player"
      src="$videoUrl"
      frameborder="0"
      allowfullscreen
      allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;" 
      loading="lazy"
    ></iframe>
    
    <script type="text/javascript" src="//cdn.embed.ly/player-0.1.0.min.js"></script>
  </body>
</html>
''';
}
// <style>
// html, body {
// margin: 0;
// padding: 0;
// background-color: #000;
// width: 100%;
// }
//
// /* 16:9 responsive container */
// #player-container {
// position: relative;
// width: 100%;
// padding-top: 56.25%; /* 16/9 ratio = 9/16 = 0.5625 */
// }
//
// #player {
// position: absolute;
// top: 0;
// left: 0;
// width: 800px;
// height: 800px;
// border: none;
// }
// </style>
// <style>
// body, html { margin: 0; padding: 0; background-color: #000; height: 100%; }
// #player { object-fit: cover; width: 100%; height: 100%; border: none; }
// </style>

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<PipProvider>(
          builder: (context, prov, _) =>Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.green,
                  ),
                  child: TextButton(
                      onPressed: () {

                        prov.IsPipVisible?prov.isdispose=true:
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InappwebView()));
                      },
                      child: Text(
                        "Bunny VideoPlayer",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.green,
                  ),
                  child: TextButton(
                      onPressed: () {

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BunnyBetterPlayer()));
                      },
                      child: Text(
                        "Custom VideoPLayer",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.green,
                  ),
                  child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ZongApp()));
                      },
                      child: Text(
                        "bogo Web View",
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
        // child: WebViewWidget(controller: _controller),
        // child: BunnyBetterPlayer(),
      ),
    );
  }
}

class InappwebView extends StatefulWidget {
  const InappwebView({super.key});

  @override
  State<InappwebView> createState() => _InappwebViewState();
}

class _InappwebViewState extends State<InappwebView> {
  InAppWebViewController? webViewController;
  ValueNotifier isShow =ValueNotifier(false);

  final String urlString = bunnyEmbedHtml(
      "https://iframe.mediadelivery.net/embed/425272/15c977d5-5132-4dc8-a913-c38b1728a74a"
      "?autoplay=true"
      "&loop=false"
      "&preload=true"
      "&responsive=true"
      "&showControls=true"
      "&showSpeed=true"
      "&skipSeconds=10");
// Helper function to define the JS injection
  String _progressTrackingJs() {
    return '''
    let lastTime = 0;
    let player =null;
    const player = new playerjs.Player('bunny-video-player');
     window.flutter_inappwebview.addJavaScriptHandler('seekVideoHandler', (data) => {
          const direction =data[0];
          const seekAmount =data[1];
          
          console.log('JS DEBUG: seekVideoHandler called. Direction:', direction, 'Amount:', seekAmount);
           if (!player) {
                console.log('JS DEBUG: Player not ready yet!');
                  return;
           }
          player.getCurrentTime((currentTime) => { 
              console.log('JS DEBUG: Current time retrieved:', currentTime);
              
              let newTime;
              if (direction === "forward") {
                  newTime = currentTime + seekAmount;
              } else {
                  newTime = currentTime - seekAmount;
              }
              if (newTime < 0) {
                  newTime = 0;
              }
              player.setCurrentTime(newTime);
              console.log(\`Video seeked \${direction} by \${seekAmount}s to \${newTime}s.\`);
          });
      });
    player.on('ready', () => {
      console.log('✅ player ready seeeeeee. Registering Handlers.');
     
      
      //player.setCurrentTime(10); // todo progress from database
      player.on('timeupdate', (data) => {
        const rawTime = data.seconds;
        
        if (rawTime !== undefined) {
            const currentTime = Math.floor(rawTime);
            
            if (currentTime >= lastTime + 5) {
                lastTime = currentTime;
                
                console.log('TIME seee:', currentTime);
                
                if (window.flutter_inappwebview) {
                    window.flutter_inappwebview.callHandler(
                        "saveProgressHandler",
                        currentTime
                    );
                }
            }
        }
      });
    });
  ''';
  }
  static const int seektime = 10;
  Future<void> _seekVideo(String direction) async {
    if (webViewController != null) {
      await webViewController!.callAsyncJavaScript(
          functionBody:
          'window.flutter_inappwebview.callHandler("seekVideoHandler", "$direction", $seektime);'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PipProvider>(
        builder: (context, prov, _) => PIPView(
              builder: (BuildContext context, bool isFloating)=> Scaffold(
        backgroundColor: Colors.white,
        appBar: !isFloating?AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              prov.IsPipVisible=false;
            },
            icon: Icon(Icons.arrow_back_ios_rounded),
          ),
          title: Text(
            "Bunny VideoPlayer",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ):null,
        body: SafeArea(
          child:AspectRatio(
            aspectRatio:16/9,
            child: Stack(

                children: [
                  GestureDetector(

                    onDoubleTapDown: (details) {
                      final double screenWidth = context.size!.width;
                      final double tapX = details.localPosition.dx;

                      if (tapX < screenWidth / 3) {
                        _seekVideo("backward");
                      } else if (tapX > screenWidth * 2 / 3) {
                        _seekVideo("forward");
                      }
                    },
                    child:
                       InAppWebView(
                        initialData: InAppWebViewInitialData(
                            data:
                                urlString,
                            baseUrl: WebUri("https://iframe.mediadelivery.net/")),
                        // initialUrlRequest: URLRequest(
                        //     url: WebUri(
                        //         "https://iframe.mediadelivery.net/embed/425272/d536d078-e1cd-4de5-83f2-526822e2d829"
                        //         "?autoplay=true"
                        //         "&loop=false"
                        //         "&preload=true"
                        //         "&responsive=true"
                        //         "&pipEnabled=true"
                        //         "&showControls=true"
                        //         "&showSpeed=true"
                        //         "&skipSeconds=10")),
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                          // The handler receives the time from the JavaScript
                          controller.addJavaScriptHandler(
                            handlerName: 'saveProgressHandler',
                            callback: (args) async {
                              if (args.isNotEmpty && args[0] is int) {
                                final int currentTime = args[0];

                                // Replace with your actual user ID and video ID logic
                                final String userId = 'current_user_id';
                                final String videoId = 'current_video_id';

                                // 2. Save the progress to your database
                                // await saveUserProgress(userId, videoId, currentTime);
                                print(
                                    'Saved progress for $userId on video $videoId at $currentTime seconds');
                              }
                            },
                          );
                        },

                        onLoadStop: (controller, url) {

                          controller.evaluateJavascript(
                              source: _progressTrackingJs());
                        },

                        onConsoleMessage: (controller, consoleMessage) {
                          print("JS consoleeeeeeeeeeee: ${consoleMessage.message}");
                        },
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          javaScriptCanOpenWindowsAutomatically: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
                          allowsPictureInPictureMediaPlayback: true,
                          allowBackgroundAudioPlaying:
                              true, //todo controls in notification
                        ),
                        initialOptions: InAppWebViewGroupOptions(
                            // crossPlatform: InAppWebViewOptions(
                            //   mediaPlaybackRequiresUserGesture: false,
                            //   supportZoom: false,
                            //
                            // ),

                            android: AndroidInAppWebViewOptions(
                              supportMultipleWindows: true,
                            ),
                            ios: IOSInAppWebViewOptions()),
                      ),

                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: IconButton(
                      onPressed: () {
                        prov.IsPipVisible=true;
                        // prov.isdispose?PIPView.of(context)?.dispose():
                        PIPView.of(context)?.presentBelow(BunnyPlayerWebView());
                        prov.isdispose=false;
                      },
                      icon: Icon(Icons.picture_in_picture_alt,
                      color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
          ),


        ),
              ),
            ));
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

    _controller = WebViewController()
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'PlayerEvents',
        onMessageReceived: (JavaScriptMessage message) {
          print("Event from player seee: ${message.message}");
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..loadHtmlString(bunnyEmbedHtml(
          "https://iframe.mediadelivery.net/embed/425272/d536d078-e1cd-4de5-83f2-526822e2d829"
          "?autoplay=true"
          "&loop=false"
          "&preload=true"
          "&responsive=true"
          "&showControls=true"
          "&showSpeed=true"
          "&skipSeconds=10"));
  }

  void runjava() async {
    try {
      await _controller.runJavaScript("""
  document.querySelector("iframe").contentWindow.document.body;
""");

      print('java');
    } catch (e) {
      print("exception");
    }
  }

  // document.querySelector('video').currentTime+=10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "webViewIframe",
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              WebViewWidget(
                controller: _controller,
              ),
              //       ElevatedButton(
              //         onPressed: () async {
              //           try {
              //             var res = await _controller.runJavaScriptReturningResult("""
              //   document.querySelector("iframe").contentWindow.document.body;
              // """);
              //             print("see $res");
              //           } catch (e) {
              //             print("JS ERROR: $e");
              //           }
              //         },
              //         child: Text("Run JS Test"),
              //       ),
            ],
          )),
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

  final List<Map<String, dynamic>> chapters = [
    {"title": "Intro", "start": Duration(seconds: 0)},
    {"title": "Part 1", "start": Duration(seconds: 10)},
    {"title": "Part 2", "start": Duration(seconds: 5)},
    {"title": "Conclusion", "start": Duration(seconds: 10)},
  ];

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: 'VideoID',
        author: 'thaqlain',
      ),
      BetterPlayerDataSourceType.network,
      "https://vz-f4ad5737-e92.b-cdn.net/15c977d5-5132-4dc8-a913-c38b1728a74a/playlist.m3u8",
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
          // customControlsBuilder: (controller, onPlayerVisibilityChanged) {
          //   return BetterPlayerMaterialControls(
          //     showControls: true,
          //     playbackSpeeds: [0.5, 1.0, 1.5], // <-- only these options
          //     playbackSpeedTextStyle: TextStyle(
          //       color: Colors.red, // change text color
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   );
          //
          //   },
          // overflowMenuCustomItems: chapters.map((chapter) {
          //   return BetterPlayerOverflowMenuItem(Icons.import_contacts, chapter['title'], (){
          //     _betterPlayerController.seekTo(chapter["start"]);
          //
          //   });
          // }).toList(),
            iconsColor: Color(0xFFF5F5F5),
            textColor:Color(0xFFF5F5F5),
            progressBarPlayedColor: Colors.red,
            progressBarHandleColor:Color(0xFFF5F5F5),
            progressBarBufferedColor: Colors.grey,
            progressBarBackgroundColor:Color(0xFFF5F5F5),
            enablePlaybackSpeed: true,
            enableSubtitles: true,
            enableSkips: true,
            enablePip: true,
            pipMenuIcon: Icons.picture_in_picture_alt,
            backgroundColor: Colors.white),
        eventListener: _handleBetterPlayerEvent,
      ),
      betterPlayerDataSource: dataSource,
    );
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        double seconds = event.parameters!['progress'];
        // save to your database
        print("Current time: $seconds");
      }
    });
    // _betterPlayerController.
  }

  void _handleBetterPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      print("Current position: ${event.parameters!["progress"]}");
    } else if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      print("Video ended");
    } else if (event.betterPlayerEventType ==
        BetterPlayerEventType.controlsVisible) {
      _showPiPButton.value = true;
    } else if (event.betterPlayerEventType ==
        BetterPlayerEventType.controlsHiddenStart) {
      _showPiPButton.value = false;
    }
  }

  void _enterPip() async {
    try {
      await _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    } catch (e) {
      debugPrint("PiP not supported / failed: $e");
    }
  }

  void seekForward() {
    final current = _betterPlayerController.videoPlayerController!.value.position;
    _betterPlayerController.seekTo(current + Duration(seconds: 10));
  }

  void seekBackward() {
    final current = _betterPlayerController.videoPlayerController!.value.position;
    _betterPlayerController.seekTo(current - Duration(seconds: 10));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        title: Text(
          "Custom VideoPLayer",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
          child: Stack(
        children: [

          AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onDoubleTapDown: (details) {
                final double screenWidth = context.size!.width;
                final double tapX = details.localPosition.dx;

                if (tapX < screenWidth / 3) {
                  seekBackward();
                } else if (tapX > screenWidth * 2 / 3) {
                  seekForward();
                }
              },
              child: BetterPlayer(
                controller: _betterPlayerController,
                key: _betterPlayerKey,
              ),
            ),
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
                        icon: Icon(Icons.picture_in_picture_alt,
                            color: Color(0xFFF5F5F5)),
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ],
      )),
    );
  }
}



