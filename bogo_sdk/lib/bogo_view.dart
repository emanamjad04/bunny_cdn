import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as console;

import 'package:bogo_sdk/shop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class BogoView extends StatefulWidget {
  final String email;
  final String password;
  final String token;

  const BogoView({
    required this.email,
    required this.password,
    super.key,
    this.token = '',
  });

  @override
  State<BogoView> createState() => _BogoViewState();
}

class _BogoViewState extends State<BogoView> {
  InAppWebViewController? _controller;
  bool _navigating = false;
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(
        InAppWebViewController.setWebContentsDebuggingEnabled(
          kDebugMode,
        ).catchError((Object error, StackTrace stackTrace) {
          debugPrint('Unable to configure WebView debugging: $error');
        }),
      );
    }
    requestPermissions();
  }

  Future<void> loadFresh() async {
    await CookieManager.instance().deleteAllCookies();
    await _controller?.clearCache();
    final webStorageManager = WebStorageManager.instance();
    await webStorageManager.deleteAllData();

    await _controller?.loadUrl(
      urlRequest: URLRequest(
        // url: WebUri("https://bogo-staging-11e83.web.app/?sdk=zong"),
        url: WebUri(
          "https://bogo-staging-11e83.web.app/onboardingScreen?sdk=zong",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authJson = jsonEncode({
      'token': widget.token,
    }); // token only, no password

    return Scaffold(
      // appBar:back? AppBar(
      //   leading: IconButton(onPressed: (){
      //     setState(() {
      //       back=false;
      //     });
      //     _controller?.goBack();
      //   }, icon: Icon(Icons.arrow_back_ios_rounded)),
      // ):null,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (_controller != null && await _controller!.canGoBack()) {
            _controller!.goBack();
          } else if (context.mounted) {
            Navigator.pop(context);
          }
        },
        // onWillPop: () async {
        //   final canGoBack = await _controller!.canGoBack();
        //   if (_controller != null && canGoBack) {
        //     _controller!.goBack();
        //     return false; // stay in WebView screen
        //   }
        //   return true; // pop the screen
        // },
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BogoView(
                          email: widget.email,
                          password: widget.password,
                          token: widget.token,
                        ),
                  ),
                );
              },
            );
            controller.addJavaScriptHandler(
              handlerName: "openExternalUrl",
              callback: (args) {
                final url = args[0];
                final code = args[1];
                final title = args[2];
                final logoUrl = args[3];
                print("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥navigating");
                console.log("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥navigating");
                if (_navigating) {
                  return;
                }
                _navigating = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ShopWeb(
                          Url: url,
                          Code: code,
                          title: title,
                          logoUrl: logoUrl,
                        ),
                  ),
                ).then((_) {
                  _navigating = false;
                });
                // _controller?.loadUrl(
                //   urlRequest: URLRequest(url: WebUri(url)),
                // );
              },
            );
            await loadFresh();
          },

          // initialUrlRequest: URLRequest(
          //   url: WebUri("https://bogo-staging-11e83.web.app/"),
          // ),
          initialSettings: InAppWebViewSettings(
            useHybridComposition: true,
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            mediaPlaybackRequiresUserGesture: false,
            useShouldOverrideUrlLoading: true,
            cacheEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            isInspectable: kDebugMode,
            hardwareAcceleration: true,
            sharedCookiesEnabled: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
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
            debugPrint(
              '🔗 nav request: $uri (mainFrame: ${action.isForMainFrame})',
            );
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
              final ok = await launchUrl(
                Uri.parse(uri.toString()),
                mode: LaunchMode.externalApplication,
              );
              debugPrint('🔗 external launch result: $ok');
            } catch (e) {
              debugPrint('🔗 external launch failed: $e');
            }
            return NavigationActionPolicy.CANCEL;
          },

          // onPermissionRequest: (controller, request) async {
          //   return PermissionResponse(
          //     resources: request.resources,
          //     action: PermissionResponseAction.GRANT,
          //   );
          // },
          onPermissionRequest: (controller, request) async {
            final ok = _appHosts.contains(request.origin.host);
            return PermissionResponse(
              resources: request.resources,
              action:
                  ok
                      ? PermissionResponseAction.GRANT
                      : PermissionResponseAction.DENY,
            );
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            final ok = _appHosts.contains(Uri.parse(origin).host);
            return GeolocationPermissionShowPromptResponse(
              origin: origin,
              allow: ok,
              retain: ok,
            );
          },

          // onGeolocationPermissionsShowPrompt: (controller, origin) async {
          //   return GeolocationPermissionShowPromptResponse(
          //     origin: origin,
          //     allow: true,
          //     retain: true,
          //   );
          // },
          onLoadStop: (controller, url) async {
            if (url == null || !_appHosts.contains(url.host)) return;

            await controller.evaluateJavascript(
              source: """
    function installBogoRestartListener() {
      const bridge = window.flutter_inappwebview;
      if (!bridge || typeof bridge.callHandler !== 'function') {
        window.addEventListener(
          'flutterInAppWebViewPlatformReady',
          installBogoRestartListener,
          { once: true }
        );
        return;
      }
      if (window.__bogoRestartListenerInstalled) return;
      window.__bogoRestartListenerInstalled = true;
      window.addEventListener('bogo-restart-web', function () {
        const readyBridge = window.flutter_inappwebview;
        if (readyBridge && typeof readyBridge.callHandler === 'function') {
          readyBridge.callHandler('bogoRestartListener');
        }
      });
    }
    installBogoRestartListener();
  """,
            );

            final detail = jsonEncode({
              'email': widget.email,
              'password': widget.password,
              'token': widget.token,
            });
            await controller.evaluateJavascript(
              source:
                  "window.dispatchEvent(new CustomEvent('bogo-auth', {detail: $detail}));",
            );
          },
        ),
      ),
    );
  }
}
