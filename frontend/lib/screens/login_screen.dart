import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart'; //
import 'forgot_password_screen.dart';
import 'register_client_screen.dart';
import 'home_client_screen.dart';
import 'barber_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;

  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  final Color accentLilac = const Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  // ==========================================
  // LÓGICA DE RECORDAR SESIÓN
  // ==========================================
  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('saved_email') ?? '';
      } else {
        prefs.remove('token');
      }
    });
  }

  Future<void> _guardarPreferencias(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);

    if (_rememberMe) {
      await prefs.setString('saved_email', email);
    } else {
      await prefs.remove('saved_email');
    }
  }

  // ==========================================
  // LÓGICA DE LOGIN CON GLASS TOASTS
  // ==========================================
  Future<void> _procesarLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      GlassToast.showWarning(context, "Atención", "Por favor, rellena todos los campos");
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      GlassToast.showWarning(context, "Email inválido", "Introduce un email válido (ej: info@ejemplo.com)");
      return;
    }

    if (password.length < 4) {
      GlassToast.showWarning(context, "Contraseña corta", "La contraseña debe tener al menos 4 caracteres");
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final usuario = await ApiService().login(email, password);

      await _guardarPreferencias(email);

      if (usuario['rolUsuario'] == 'BARBERO') {
        //  TOAST DE ÉXITO PREMIUM PARA BARBERO
        if (mounted) GlassToast.showSuccess(context, "¡Hola de nuevo!", "Bienvenido a tu panel de control.");

        if (mounted) {
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
        }
      } else {
        //  TOAST DE ÉXITO PREMIUM PARA CLIENTE
        if (mounted) GlassToast.showSuccess(context, "¡Bienvenido!", "Qué alegría volver a verte.");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeClientScreen(idUsuarioCliente: usuario['idUsuario'])),
          );
        }
      }
    } catch (e) {
      //  TOAST DE ERROR PREMIUM
      if (mounted) {
        GlassToast.showError(context, "Error de acceso", e.toString().replaceAll('Exception: ', ''));
      }
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
                Center(
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
                    child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text("Iniciar sesión ", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterClientScreen())); },
                      child: Text("/ Regístrate", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Rellena el formulario para entrar en tu cuenta", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                const SizedBox(height: 40),

                _buildGlassCardField(label: "Email", hint: "Introduce tu email", controller: _emailController, isPassword: false, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildGlassCardField(label: "Contraseña", hint: "Introduce tu contraseña", controller: _passwordController, isPassword: true),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        const Text("RECORDAR", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())); },
                      child: const Text("¿Contraseña olvidada?", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildGlowingVibrantButton("Iniciar Sesión", _procesarLogin),
                const SizedBox(height: 80),
                Center(child: Text("DARKMATTER", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4.0))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCardField({required String label, required String hint, required TextEditingController controller, required bool isPassword, TextInputType keyboardType = TextInputType.text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: accentLilac, fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 5),
              TextField(
                controller: controller, obscureText: isPassword, keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white, fontSize: 16), cursorColor: Colors.white,
                decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14), contentPadding: EdgeInsets.zero, border: InputBorder.none, isDense: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingVibrantButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity, height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: vibrantPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: vibrantPurple, foregroundColor: Colors.white, elevation: 0, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}