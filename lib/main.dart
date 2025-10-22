import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Screens
import 'package:eval_plus/screen/splash_screen.dart';
import 'package:eval_plus/screen/home_screen.dart';
import 'package:eval_plus/screen/inside_screen.dart';

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
      title: 'Eval+',
      home: const SplashScreen(),
      routes: {
        HomeScreen.routename: (context) => const HomeScreen(),
        InsideScreen.routename: (context) => const InsideScreen(),
      },
    );
  }
}
