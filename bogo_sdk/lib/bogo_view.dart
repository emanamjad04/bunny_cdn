import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as console;

import 'package:bogo_sdk/shop.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class BogoView extends StatefulWidget {
  final String email;
  final String password;
  final String token;

  const BogoView({required this.email, required this.password, super.key, this.token = ''});

  @override
  State<BogoView> createState() => _BogoViewState();
}

class _BogoViewState extends State<BogoView> {
  Timer? _authInjectTimer;

  InAppWebViewController? _controller;
  bool _navigating = false;
  String? _cachedToken;
  String token = '';
  static const _appHosts = {
    'bogo-staging-11e83.web.app',
    'bogo-staging-11e83.firebaseapp.com',
  };

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.locationWhenInUse.request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    loadFresh();
  }



  Future<void> loadFresh() async {
    final version = DateTime.now().millisecondsSinceEpoch;

    await CookieManager.instance().deleteAllCookies();
    await _controller?.clearCache();
    final webStorageManager = WebStorageManager.instance();
    await webStorageManager.deleteAllData();

    await _controller?.loadUrl(
      urlRequest: URLRequest(
        // url: WebUri("https://bogo-staging-11e83.web.app/?sdk=zong"),
        url: WebUri("https://bogo-staging-11e83.web.app/onboardingScreen?sdk=zong"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authJson = jsonEncode({'token': widget.token}); // token only, no password

    return Scaffold(
      // appBar:back? AppBar(
      //   leading: IconButton(onPressed: (){
      //     setState(() {
      //       back=false;
      //     });
      //     _controller?.goBack();
      //   }, icon: Icon(Icons.arrow_back_ios_rounded)),
      // ):null,
      body: WillPopScope(
        onWillPop: () async {
          final canGoBack = await _controller!.canGoBack();
          if (_controller != null && canGoBack) {
            _controller!.goBack();
            return false; // stay in WebView screen
          }
          return true; // pop the screen
        },
        child: InAppWebView(

          onWebViewCreated: (controller) async {

            _controller = controller;

            controller.addJavaScriptHandler(
              handlerName: 'getBogoAuth',
              callback: (_) {
                debugPrint('getBogoAuth: Token $token');
                return {'token': widget.token};
              },
            );

            controller?.addJavaScriptHandler(
              handlerName: 'bogoRestartListener',
              callback: (args) async {
                print('WebView restart triggered!');
                // Pop + push or reload WebView
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BogoView(email: widget.email, password: widget.password)));
              },
            );
            controller.addJavaScriptHandler(
              handlerName: "openExternalUrl",
              callback: (args) {
                final url = args[0];
                final code =args[1];
                final title =args[2];
                final logoUrl =args[3];
                print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥navigating");
                console.log("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥navigating");
                if(_navigating){
                  return;
                }
                _navigating=true;
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ShopWeb(Url: url, Code: code, title: title, logoUrl: logoUrl,))).then((_){
                  _navigating=false;
                });
                // _controller?.loadUrl(
                //   urlRequest: URLRequest(url: WebUri(url)),
                // );

              },
            );
            loadFresh();
          },

          // initialUrlRequest: URLRequest(
          //   url: WebUri("https://bogo-staging-11e83.web.app/"),
          // ),
          initialSettings: InAppWebViewSettings(
            useHybridComposition: true,
            hardwareAcceleration: true,
            // cacheEnabled: false,
            // clearCache: true,
            mediaPlaybackRequiresUserGesture: false,
            sharedCookiesEnabled: true,
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            useShouldOverrideUrlLoading: true,
          ),
          initialUserScripts: UnmodifiableListView([
            UserScript(
              source: 'window.__bogoAuthData = $authJson;',
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              // forMainFrameOnly defaults to true, which is what you want
            ),
          ]),

          onConsoleMessage: (controller, consoleMessage) {
            print("Console: ${consoleMessage.message}");
          },

          shouldOverrideUrlLoading: (controller, action) async {
            final uri = action.request.url;
            debugPrint('🔗 nav request: $uri (mainFrame: ${action.isForMainFrame})');
            if (uri == null) return NavigationActionPolicy.ALLOW;

            const internalSchemes = {'about', 'blob', 'data', 'javascript'};
            final isWeb = uri.scheme == 'http' || uri.scheme == 'https';

            if (internalSchemes.contains(uri.scheme) ||
                (isWeb && _appHosts.contains(uri.host))) {
              return NavigationActionPolicy.ALLOW;
            }

            // Don't gate on isForMainFrame here: popup/_blank navigations
            // can be reported as non-main-frame on some Android versions.
            try {
              final ok = await launchUrl(Uri.parse(uri.toString()),
                  mode: LaunchMode.externalApplication);
              debugPrint('🔗 external launch result: $ok');
            } catch (e) {
              debugPrint('🔗 external launch failed: $e');
            }
            return NavigationActionPolicy.CANCEL;
          },

          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },

          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: true,
              retain: true,
            );
          },

          onLoadStop: (controller, url) async {
            try{
              console.log("seeeeeeeee token work below");
              _cachedToken??=  await FirebaseAppCheck.instance.getToken();
              print("seeeeeeeeeeee token 🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥$_cachedToken");
              if(_cachedToken!=null){
                await controller.evaluateJavascript(source: """
            window.appCheckToken='$_cachedToken';
            localStorage.setItem('appCheckToken','$_cachedToken');
            console.log("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥Token secured");
            
            """);
              }
            }catch(e){
              if(e.toString().contains("too-many-attempts")){
                print("CRITICAL: App Check throttled. Wait a few minutes before retrying");
              }
              print("Exception seee 🔥🔥🔥$e");
            }
            // await Future.delayed(Duration(milliseconds: 600));

            await controller.evaluateJavascript(
              source: """
          window.addEventListener('bogo-restart-web', function() {
            window.flutter_inappwebview.callHandler('bogoRestartListener');
          });
        """,
            );
            ///don't call at load stop it creates race condition
            await controller.evaluateJavascript(
              source: """
                  console.log("🔥🔥🔥 ABOUT TO SEND BOGO AUTH");

              window.dispatchEvent(new CustomEvent('bogo-auth', {
                detail: { email: '${widget.email}', password: '${widget.password}', token: '${jsonEncode(widget.token)}'}
              }));

                  console.log("🔥🔥🔥 BOGO AUTH SENT");

            """,
            );

          },

          // onLoadStop: (controller, url) async {
          //   await Future.delayed(Duration(milliseconds: 600));
          //
          //   await controller.evaluateJavascript(source: """
          //   if (!localStorage.getItem('bogo-logged-in')) {
          //     console.log("Firsttime login event sent");
          //
          //     window.dispatchEvent(new CustomEvent('bogo-auth', {
          //       detail: {
          //         email: '${widget.email}',
          //         password: '${widget.password}'
          //       }
          //     }));
          //
          //     localStorage.setItem('bogo-logged-in', 'true');
          //   } else {
          //     console.log("Already logged in");
          //   }
          // """);
          // },
          // onLoadStop: (controller, url) async {
          //   await Future.delayed(const Duration(milliseconds: 600));
          //
          //   if (!_alreadyLoggedIn) {
          //     print("Sending login eventtt");
          //     await controller.evaluateJavascript(source: """
          //             window.dispatchEvent(new CustomEvent('bogo-auth', {
          //               detail: {
          //                 email: '${widget.email}',
          //                 password: '${widget.password}'
          //               }
          //             }));
          //           """);
          //     _alreadyLoggedIn = true;
          //   } else {
          //     print("Already logged in");
          //   }
          // },
        ),
      ),
    );
  }
}
