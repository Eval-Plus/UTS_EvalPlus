import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:eval_plus/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de animación
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/animations/uts_animation_cyan-teal.json',
          controller: _controller,
          onLoaded: (composition) async {
            // Ajusta la duración
            _controller.duration = composition.duration;

            // Pausa de 1 segundo al final
            await Future.delayed(const Duration(milliseconds: 500));

            // Reproduce la animación
            await _controller.forward();

            // Pausa de 1 segundo al final
            await Future.delayed(const Duration(milliseconds: 500));

            if (mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition (
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 1600),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
