import 'package:bogo_sdk/bogo_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class ZongApp extends StatefulWidget {
  const ZongApp({super.key});

  @override
  State<ZongApp> createState() => _ZongAppState();
}

class _ZongAppState extends State<ZongApp> {

  Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.locationWhenInUse.request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  final email = "x5@bogo.com";
  final password = "00000000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.close)),
      ),
      body: BogoView(email: "x5@bogo.com", password: "00000000"),
    );
  }
}

// import 'dart:html' as html;
//
// void main() {
//   runApp(MyApp());
//
//   html.window.addEventListener('bogo-auth', (event) {
//     final customEvent = event as html.CustomEvent;
//     final msg = customEvent.detail['msg'];
//        print("seeeeee");
//     print(token)
//
//   });
// }
