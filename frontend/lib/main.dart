import 'package:flutter/material.dart';
// Importamos la pantalla de carga que creamos antes
import 'screens/splash_screen.dart';

void main() {
  runApp(const BookcutApp());
}

class BookcutApp extends StatelessWidget {
  const BookcutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookcut',
      // Esto quita la etiqueta roja fea de "DEBUG" que sale arriba a la derecha en el emulador
      debugShowCheckedModeBanner: false,

      // Configuramos el tema visual de toda la aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF381483), // Vuestro morado oscuro
          primary: const Color(0xFFE96D71),   // Vuestro rojizo/salmón
        ),
        useMaterial3: true, // Usa las animaciones y estilos más modernos de Flutter
      ),

      // Aquí le decimos que la primera pantalla que debe abrir es el Splash
      home: SplashScreen(),
    );
  }
}