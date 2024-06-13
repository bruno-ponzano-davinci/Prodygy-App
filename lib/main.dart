import 'package:flutter/material.dart';

import 'package:prodygy/pages/auth_page.dart';
import 'package:prodygy/pages/edit_profile.dart';
import 'package:prodygy/pages/home_page.dart';
import 'package:prodygy/pages/login_page.dart';
import 'package:prodygy/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HomePage(),
        '/main': (context) => MainPage(),
        '/edit_profile': (context) => EditProfile(),
      },
    );
  }
}
