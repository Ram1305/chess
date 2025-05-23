// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDLE0u9ioa-H7XZHRJiKNdCG1C45COb3bg',
    appId: '1:836248360559:web:9d1645041d1561eea5df9a',
    messagingSenderId: '836248360559',
    projectId: 'ornam-2fb07',
    authDomain: 'ornam-2fb07.firebaseapp.com',
    databaseURL: 'https://ornam-2fb07-default-rtdb.firebaseio.com',
    storageBucket: 'ornam-2fb07.appspot.com',
    measurementId: 'G-KMDDJY89T8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaLKDhjxpiJGHPG42basZSte_ztxviBHw',
    appId: '1:836248360559:android:058e31b82d654afda5df9a',
    messagingSenderId: '836248360559',
    projectId: 'ornam-2fb07',
    databaseURL: 'https://ornam-2fb07-default-rtdb.firebaseio.com',
    storageBucket: 'ornam-2fb07.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWBH-rZKUGwV-43vQQQc8HoMVqn-gela0',
    appId: '1:836248360559:ios:a9d6eda17f4f090ea5df9a',
    messagingSenderId: '836248360559',
    projectId: 'ornam-2fb07',
    databaseURL: 'https://ornam-2fb07-default-rtdb.firebaseio.com',
    storageBucket: 'ornam-2fb07.appspot.com',
    iosClientId: '836248360559-hdf1f0j5a01j7578dnspp5pcar89n270.apps.googleusercontent.com',
    iosBundleId: 'com.example.instavideo',
  );
}
