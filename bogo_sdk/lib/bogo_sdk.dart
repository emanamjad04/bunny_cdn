library bogo_sdk;

import 'package:firebase_core/firebase_core.dart';

export 'bogo_view.dart';

class BogoSDK {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBRrPWRX2hL4t8GxLinWLkIBJ4QUtZmsq8',
        appId:
            '1:952291398487:android:7ac5544cbc918b9d43a412', // Found in Firebase Console
        messagingSenderId: '952291398487',
        projectId: 'bogo-staging-11e83',
      ),
    );
  }
}
