

import 'package:chat_app_harsh_rp/provider/auth_provider.dart';
import 'package:chat_app_harsh_rp/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI mode to immersive sticky
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());

  // Lock orientation to portrait up and down
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]).then((_)  {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 7,

            backgroundColor: Colors.green,
          )
      ),
      home:SplashScreen(),
    );
  }
}