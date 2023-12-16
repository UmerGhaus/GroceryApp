// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB3cvCohsa-7XnKRk4W01lISSFpMEt2heU',
    appId: '1:766216458983:web:21b2331570ec2e7f59c842',
    messagingSenderId: '766216458983',
    projectId: 'my-grocery-app-38c0e',
    authDomain: 'my-grocery-app-38c0e.firebaseapp.com',
    storageBucket: 'my-grocery-app-38c0e.appspot.com',
    measurementId: 'G-KDK4BGCTTB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuQMXU-0hFR8B-W5AcxmbZq8pHua0l6VM',
    appId: '1:766216458983:android:60a5ee2f5d5e5fec59c842',
    messagingSenderId: '766216458983',
    projectId: 'my-grocery-app-38c0e',
    storageBucket: 'my-grocery-app-38c0e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAyg029eOjPgkR__-VW7vY7RxOyurQ4Ic4',
    appId: '1:766216458983:ios:bd6f42f36362e99359c842',
    messagingSenderId: '766216458983',
    projectId: 'my-grocery-app-38c0e',
    storageBucket: 'my-grocery-app-38c0e.appspot.com',
    iosBundleId: 'com.example.groceryApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAyg029eOjPgkR__-VW7vY7RxOyurQ4Ic4',
    appId: '1:766216458983:ios:0686ffc963dfe95859c842',
    messagingSenderId: '766216458983',
    projectId: 'my-grocery-app-38c0e',
    storageBucket: 'my-grocery-app-38c0e.appspot.com',
    iosBundleId: 'com.example.groceryApp.RunnerTests',
  );
}