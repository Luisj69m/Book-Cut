import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'success_client_screen.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _aceptaTerminos = false;
  bool _isLoading = false;

  // Colores corporativos
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  // Un morado variante más claro para el botón o elementos interactivos
  final Color vibrantPurple = const Color(0xFF6200EA);

  // FUNCIONALIDAD INTÁCTA (No modificada)
  void _procesarRegistro() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, rellena todos los campos'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce un email válido (ej: info@ejemplo.com)'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 4 caracteres'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      print("Registrando Cliente... Email: $email");

      await ApiService().registrarUsuario(
          "Usuario",
          "",
          email,
          password,
          "",
          "CLIENTE"
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessClientScreen()),
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // REDISEÑO VISUAL CON DEGRADADO, CRISTAL Y COLORES COMPLEMENTARIOS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ✅ DEGRADADO RADIAL CORPORATIVO (Fondo)
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [
              pinkAccent,
              deepPurple,
            ],
          ),
        ),
        child: Column(
          children: [
            // ── HEADER SUPERIOR ──
            Expanded(
              flex: 3,
              child: Center(
                child: SafeArea(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8)
                          )
                        ]
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),

            // ── TARJETA DE REGISTRO FLOTANTE (Efecto Cristal) ──
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  // ✅ EFECTO GLASSMORPHISM (DIFUMINADO)
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07), // Cristal semi-transparente
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.5
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Botón Atrás
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Título Sección
                            const Text(
                              "Crea tu cuenta",
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Registra tus datos para empezar",
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                            ),

                            const SizedBox(height: 40),

                            // Campos de texto (Estilo Outlined, adaptado al cristal)
                            _buildGlassTextField("Email", "info@ejemplo.com", _emailController, false, TextInputType.emailAddress),
                            const SizedBox(height: 25),

                            _buildGlassTextField("Contraseña", "***************", _passwordController, true),
                            const SizedBox(height: 25),

                            _buildGlassTextField("Confirmar Contraseña", "***************", _confirmPasswordController, true),
                            const SizedBox(height: 25),

                            // Términos y Condiciones
                            Row(
                              children: [
                                Checkbox(
                                  value: _aceptaTerminos,
                                  activeColor: vibrantPurple, // Variante morada complementaria
                                  side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _aceptaTerminos = value ?? false;
                                    });
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    "Acepto los términos y condiciones de uso.",
                                    style: TextStyle(fontSize: 13, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 35),

                            // Botón Registrar (Complementario/Variante)
                            _buildGlowingVibrantButton("Registrarse", _procesarRegistro),

                            // Eliminados iconos sociales inferiores

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Campo de texto con estilo Cristal/Líneas sutiles
  Widget _buildGlassTextField(String label, String hint, TextEditingController controller, bool isPassword, [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET: Botón con Brillo y Color Variante Morada (VibrantPurple)
  Widget _buildGlowingVibrantButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 55, // Más alto = más premium
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // ✅ BRILLO CORPORATIVO
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