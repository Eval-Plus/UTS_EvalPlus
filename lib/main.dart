import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:eval_plus/screen/splash_screen.dart';
import 'package:eval_plus/screen/home_screen.dart';
import 'package:eval_plus/screen/inside_screen.dart';

// Controllers
import 'package:eval_plus/controllers/user_session_controller.dart';

void main() {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔒 Bloquear orientación solo a modo vertical (portrait)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar modo inmersivo (ocultar barras del sistema)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // Sin overlays = oculta barra superior e inferior
  );
  
  // Configurar el estilo de la barra de navegación (por si se muestra momentáneamente)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserSessionController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eval+',
        home: const SplashScreen(),
        routes: {
          HomeScreen.routename: (context) => const HomeScreen(),
          InsideScreen.routename: (context) => const InsideScreen(),
        },
      ),
    );
  }
}