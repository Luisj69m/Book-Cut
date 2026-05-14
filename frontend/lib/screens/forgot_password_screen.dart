import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart'; // ✅ IMPORTAMOS NUESTRO TOAST PREMIUM

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ApiService _apiService = ApiService();

  // Controladores
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 1; // Paso 1: Pedir email | Paso 2: Pedir código y nueva clave
  bool _obscurePassword = true;

  // Colores corporativos y complementarios
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  final Color accentLilac = const Color(0xFFB388FF);

  // Lógica Paso 1
  Future<void> _solicitarCodigo() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      GlassToast.showWarning(context, "Atención", "Introduce un correo electrónico válido");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exito = await _apiService.solicitarRecuperacionPassword(email);

      if (exito) {
        GlassToast.showSuccess(context, "Código enviado", "Revisa la bandeja de entrada de tu correo");
        setState(() => _currentStep = 2);
      }
    } catch (e) {
      GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Lógica Paso 2
  Future<void> _cambiarContrasena() async {
    final codigo = _codeController.text.trim();
    final nuevaClave = _passwordController.text.trim();

    if (codigo.length != 6 || nuevaClave.length < 4) {
      GlassToast.showWarning(context, "Atención", "Código inválido o contraseña muy corta");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exito = await _apiService.confirmarRecuperacion(codigo, nuevaClave);
      if (exito) {
        GlassToast.showSuccess(context, "¡Completado!", "Contraseña actualizada con éxito");
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                          "Recuperar Acceso",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)
                      ),
                    ),
                    const SizedBox(width: 40), // Balance visual para centrar el texto
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- ICONO GLOWING ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: accentLilac.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: vibrantPurple.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)
                    ]
                ),
                child: Icon(Icons.lock_reset_rounded, size: 50, color: Colors.white.withOpacity(0.9)),
              ),

              const SizedBox(height: 35),

              // --- TARJETA DE CRISTAL (FORMULARIO) ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            child: _currentStep == 1 ? _buildPaso1() : _buildPaso2(),
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
      ),
    );
  }

  // --- INTERFAZ PASO 1: Pedir Correo ---
  Widget _buildPaso1() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("¿Olvidaste tu contraseña?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 10),
        Text(
            "Introduce tu correo electrónico y te enviaremos un código de 6 dígitos para restablecerla.",
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4)
        ),
        const SizedBox(height: 35),

        _buildGlassTextField(
            label: "Correo electrónico",
            hint: "ejemplo@correo.com",
            icono: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress
        ),

        const SizedBox(height: 40),

        _buildGlowingVibrantButton("Enviar código", _solicitarCodigo),
      ],
    );
  }

  // --- INTERFAZ PASO 2: Introducir Código y Nueva Contraseña ---
  Widget _buildPaso2() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Introduce el código", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 10),
        Text(
            "Hemos enviado un código a ${_emailController.text}. Revisa tu bandeja de entrada o spam.",
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4)
        ),
        const SizedBox(height: 35),

        // Input Código (Estilo especial)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Código de seguridad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentLilac)),
            const SizedBox(height: 8),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 15, fontWeight: FontWeight.w900, color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 15),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: accentLilac, width: 2),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // Input Nueva Contraseña
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nueva contraseña", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentLilac)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.5), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white.withOpacity(0.5)),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: accentLilac),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        _buildGlowingVibrantButton("Actualizar contraseña", _cambiarContrasena),

        const SizedBox(height: 15),

        // Botón para volver atrás
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _currentStep = 1;
              _codeController.clear();
              _passwordController.clear();
            }),
            child: Text("Usar otro correo electrónico", style: TextStyle(color: accentLilac, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  // --- WIDGETS REUTILIZABLES ---

  Widget _buildGlassTextField({
    required String label,
    required String hint,
    required IconData icono,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentLilac)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            prefixIcon: Icon(icono, color: Colors.white.withOpacity(0.5), size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentLilac),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingVibrantButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 55,
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
          backgroundColor: vibrantPurple,
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