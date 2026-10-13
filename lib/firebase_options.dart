import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAziRQ1XwqgmwLfp86hdxIX2nOgBMWKMcM',
    appId: '1:565044888268:web:b39d86861d1bbe9e1ef869',
    messagingSenderId: '565044888268',
    projectId: 'todo-3f942',
    authDomain: 'todo-3f942.firebaseapp.com',
    databaseURL: 'https://todo-3f942-default-rtdb.firebaseio.com',
    storageBucket: 'todo-3f942.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyClwY9pyRuKtWpDW1IIG_Jx0ZZktdLRkvI',
    appId: '1:565044888268:android:99e135f1f5af90451ef869',
    messagingSenderId: '565044888268',
    projectId: 'todo-3f942',
    databaseURL: 'https://todo-3f942-default-rtdb.firebaseio.com',
    storageBucket: 'todo-3f942.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBu-GMBa8Vh5s5U6R39vQp6rNmG3l0SXOw',
    appId: '1:565044888268:ios:10bd4ace3b81653e1ef869',
    messagingSenderId: '565044888268',
    projectId: 'todo-3f942',
    databaseURL: 'https://todo-3f942-default-rtdb.firebaseio.com',
    storageBucket: 'todo-3f942.firebasestorage.app',
    iosBundleId: 'com.example.fawateery',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBu-GMBa8Vh5s5U6R39vQp6rNmG3l0SXOw',
    appId: '1:565044888268:ios:10bd4ace3b81653e1ef869',
    messagingSenderId: '565044888268',
    projectId: 'todo-3f942',
    databaseURL: 'https://todo-3f942-default-rtdb.firebaseio.com',
    storageBucket: 'todo-3f942.firebasestorage.app',
    iosBundleId: 'com.example.fawateery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAziRQ1XwqgmwLfp86hdxIX2nOgBMWKMcM',
    appId: '1:565044888268:web:80d3f4b6ccf5a5b21ef869',
    messagingSenderId: '565044888268',
    projectId: 'todo-3f942',
    authDomain: 'todo-3f942.firebaseapp.com',
    databaseURL: 'https://todo-3f942-default-rtdb.firebaseio.com',
    storageBucket: 'todo-3f942.firebasestorage.app',
  );
}
