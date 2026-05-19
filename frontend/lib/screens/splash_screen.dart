import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_client_screen.dart';
import 'barber_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuramos la animación de fundido (Fade In)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    // En lugar del Timer fijo, llamamos a nuestra función inteligente
    _verificarSesion();
  }

  // ==========================================
  // LÓGICA DE AUTO-LOGIN
  // ==========================================
  Future<void> _verificarSesion() async {
    // 1. Respetamos tus 3.5 segundos exactos para que la animación se vea perfecta
    await Future.delayed(const Duration(milliseconds: 3500));

    // 2. Leemos la memoria del móvil
    final prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool('remember_me') ?? false;
    final String? token = prefs.getString('token');
    final String? rol = prefs.getString('rol_usuario');
    final String? email = prefs.getString('email_usuario');
    final int? idUsuario = prefs.getInt('id_usuario'); // ID que guardamos en el login

    if (!mounted) return;

    // 3. Decidimos a dónde mandar al usuario
    if (rememberMe && token != null && token.isNotEmpty && idUsuario != null) {
      //  TIENE SESIÓN GUARDADA
      if (rol == 'BARBERO') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BarberHomeScreen(
              barberName: email != null ? email.split('@')[0] : 'Barbero',
              shopName: "La Rodola BarberShop",
              idUsuarioBarbero: idUsuario,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeClientScreen(idUsuarioCliente: idUsuario),
          ),
        );
      }
    } else {
      //  NO TIENE SESIÓN O NO MARCÓ "RECORDAR"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // El degradado de fondo (morado a rojizo en la parte superior)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6), // Foco rojizo arriba
            radius: 1.2,
            colors: [
              Color(0xFFE96D71), // Tono rojizo/salmón
              Color(0xFF381483), // Tono morado oscuro
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ]
                  ),
                  // Aquí cargamos tu logo.
                  child: ClipOval(
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: Text(
                  "DARKMATTER",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2.0,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}