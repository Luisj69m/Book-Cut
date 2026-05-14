import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';
import 'register_client_screen.dart';
import 'home_client_screen.dart';
import 'barber_home_screen.dart'; // Importamos la pantalla del barbero

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variable para controlar si estamos esperando respuesta del servidor
  bool _isLoading = false;
  // Variable estética para el interruptor "Recordar" de la interfaz
  bool _rememberMe = false;

  // Colores corporativos y complementarios
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  // NUEVO COLOR: Un lila/lavanda suave y luminoso ideal para fondos oscuros
  final Color accentLilac = const Color(0xFFB388FF);

  // ==========================================
  // LÓGICA INTACTA
  // ==========================================
  Future<void> _procesarLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validaciones de seguridad
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un email válido (ej: info@ejemplo.com)'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 4 caracteres'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Llamamos a nuestro ApiService
      final usuario = await ApiService().login(email, password);

      // Usamos 'rolUsuario' tal como lo manda el servidor
      if (usuario['rolUsuario'] == 'BARBERO') {
        print("¡Es un barbero! ID: ${usuario['idUsuario']}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Bienvenido Barbero!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BarberHomeScreen(
              barberName: usuario['correoElectronico'].split('@')[0],
              shopName: "La Rodola BarberShop",
              idUsuarioBarbero: usuario['idUsuario'],
            ),
          ),
        );

      } else {
        print("¡Es un cliente! ID: ${usuario['idUsuario']}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Bienvenido Cliente!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  HomeClientScreen(idUsuarioCliente: usuario['idUsuario'])),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Fondo degradado
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [pinkAccent, deepPurple],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── LOGO SUPERIOR ──
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                        ]
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ── TÍTULOS ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text("Iniciar sesión ", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterClientScreen()));
                      },
                      child: Text("/ Regístrate", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Rellena el formulario para entrar en tu cuenta",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),

                const SizedBox(height: 40),

                // ── TARJETAS INDIVIDUALES DE CRISTAL ──
                _buildGlassCardField(
                  label: "Email",
                  hint: "Introduce tu email",
                  controller: _emailController,
                  isPassword: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildGlassCardField(
                  label: "Contraseña",
                  hint: "Introduce tu contraseña",
                  controller: _passwordController,
                  isPassword: true,
                ),

                const SizedBox(height: 25),

                // ── TOGGLE Y CONTRASEÑA OLVIDADA ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Switch RECORDAR
                    Row(
                      children: [
                        Switch(
                          value: _rememberMe,
                          activeColor: vibrantPurple,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          onChanged: (bool value) {
                            setState(() => _rememberMe = value);
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "RECORDAR",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                        ),
                      ],
                    ),

                    // Texto Olvidé contraseña
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                      },
                      child: const Text(
                        "¿Contraseña olvidada?",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ── BOTÓN PRINCIPAL ──
                _buildGlowingVibrantButton("Iniciar Sesión", _procesarLogin),

                const SizedBox(height: 80),

                // ── FIRMA DARKMATTER ──
                Center(
                  child: Text(
                    "DARKMATTER",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET: Campo de texto dentro de una tarjeta individual de cristal
  Widget _buildGlassCardField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isPassword,
    TextInputType keyboardType = TextInputType.text
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07), // Cristal semi-transparente
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👇 AQUÍ SE APLICA EL NUEVO COLOR LILA SUAVE
              Text(label, style: TextStyle(color: accentLilac, fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 5),
              TextField(
                controller: controller,
                obscureText: isPassword,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none, // Eliminamos el borde del TextField para usar el de la tarjeta
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Botón con Brillo y Color Variante Morada (VibrantPurple)
  Widget _buildGlowingVibrantButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 55, // Más alto = más premium
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: vibrantPurple.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantPurple, // Variante morada complementaria
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}