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
    apiKey: 'AIzaSyCz9g-xPlgJYSqvPUD_f6GZvQha8jbCs7A',
    appId: '1:717238773562:web:3cc0a3a04cbee038275203',
    messagingSenderId: '717238773562',
    projectId: 'bikepath24',
    authDomain: 'bikepath24.firebaseapp.com',
    databaseURL: 'https://bikepath24-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bikepath24.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUVGNk3f1JCl9YLJpeX-LBRxEck_r4UZo',
    appId: '1:717238773562:android:422bc5ca2cbe2ae6275203',
    messagingSenderId: '717238773562',
    projectId: 'bikepath24',
    databaseURL: 'https://bikepath24-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bikepath24.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGUnZIn067i7pZ4gHSCOp-pha5isKzsus',
    appId: '1:717238773562:ios:af6862bfe1c5de3d275203',
    messagingSenderId: '717238773562',
    projectId: 'bikepath24',
    databaseURL: 'https://bikepath24-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bikepath24.appspot.com',
    iosBundleId: 'com.example.bikepath',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCGUnZIn067i7pZ4gHSCOp-pha5isKzsus',
    appId: '1:717238773562:ios:0ba1e975106037e9275203',
    messagingSenderId: '717238773562',
    projectId: 'bikepath24',
    databaseURL: 'https://bikepath24-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bikepath24.appspot.com',
    iosBundleId: 'com.example.bikepath.RunnerTests',
  );
}