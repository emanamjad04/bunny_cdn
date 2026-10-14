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
      body: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
        // child: BogoView(email: "x5@bogo.com", password: "00000000"),
        child: BogoView(email: "zong7@rt.com", password: "12345678", token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImlkIjo0OTc0ODMsImlzRW1haWxWZXJpZmllZCI6ZmFsc2UsImlzUGhvbmVWZXJpZmllZCI6dHJ1ZSwic2Vzc2lvbiI6IjE3OTE5NTczNzg2NTgiLCJkZXZpY2VJZCI6bnVsbH0sImlhdCI6MTc5MTk1NzM3OCwiZXhwIjoxNzkyMDExMzc4fQ.9ln8U_1xUd_ojxFAm5fuF_9QOqiBwV7104K3SQyPg9Q',),
      ),
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
