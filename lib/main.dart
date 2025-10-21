import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Screens
import 'package:eval_plus/screen/splash_screen.dart';
import 'package:eval_plus/screen/home_screen.dart';
import 'package:eval_plus/screen/inside/careers_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTS SelfEvaluate',
      home: const SplashScreen(),
      routes: {
        CareersScreen.routename: (context) => const CareersScreen(),
        HomeScreen.routename: (context) => const HomeScreen(),
      },
    );
  }
}
