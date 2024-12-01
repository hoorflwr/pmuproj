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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCWw7TROXpqlG0egm58ZMqHNXK7FBWwur4',
    appId: '1:382735159927:web:e484a9004381b1215dec72',
    messagingSenderId: '382735159927',
    projectId: 'pumentor-b183c',
    authDomain: 'pumentor-b183c.firebaseapp.com',
    storageBucket: 'pumentor-b183c.firebasestorage.app',
    measurementId: 'G-05RV6QKZER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUzg6PZwBzm6uy4z7s2-yh0BFypFHyBVA',
    appId: '1:382735159927:android:64bd1f636a8a081c5dec72',
    messagingSenderId: '382735159927',
    projectId: 'pumentor-b183c',
    storageBucket: 'pumentor-b183c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDfUNfHbMi_REwtAVZHveQkNGYPo-8AT-U',
    appId: '1:382735159927:ios:2536dfbea5830ea85dec72',
    messagingSenderId: '382735159927',
    projectId: 'pumentor-b183c',
    storageBucket: 'pumentor-b183c.firebasestorage.app',
    iosBundleId: 'com.example.pmuMentor',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDfUNfHbMi_REwtAVZHveQkNGYPo-8AT-U',
    appId: '1:382735159927:ios:2536dfbea5830ea85dec72',
    messagingSenderId: '382735159927',
    projectId: 'pumentor-b183c',
    storageBucket: 'pumentor-b183c.firebasestorage.app',
    iosBundleId: 'com.example.pmuMentor',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCWw7TROXpqlG0egm58ZMqHNXK7FBWwur4',
    appId: '1:382735159927:web:97b5c17d76284ba25dec72',
    messagingSenderId: '382735159927',
    projectId: 'pumentor-b183c',
    authDomain: 'pumentor-b183c.firebaseapp.com',
    storageBucket: 'pumentor-b183c.firebasestorage.app',
    measurementId: 'G-R1Y66NFTWR',
  );
}