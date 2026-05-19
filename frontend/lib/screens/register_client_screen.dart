import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/api_service.dart';
import 'success_client_screen.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  // CONTROLADORES
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variable para guardar el teléfono final (Prefijo + Número)
  String _telefonoCompleto = "";

  bool _aceptaTerminos = false;
  bool _isLoading = false;

  // Colores corporativos
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  final Color accentLilac = const Color(0xFFB388FF);

  // ==========================================
  // LÓGICA DE REGISTRO
  // ==========================================
  void _procesarRegistro() async {
    String nombre = _nombreController.text.trim();
    String apellidos = _apellidosController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validaciones
    if (nombre.isEmpty || apellidos.isEmpty || email.isEmpty || _telefonoCompleto.isEmpty || password.isEmpty) {
      _mostrarSnackBar('Por favor, rellena todos los campos', Colors.orange);
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _mostrarSnackBar('Introduce un email válido', Colors.orange);
      return;
    }

    if (password.length < 4) {
      _mostrarSnackBar('La contraseña debe tener al menos 4 caracteres', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _mostrarSnackBar('Las contraseñas no coinciden', Colors.redAccent);
      return;
    }

    if (!_aceptaTerminos) {
      _mostrarSnackBar('Debes aceptar los términos y condiciones', Colors.orange);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await ApiService().registrarUsuario(
          nombre,
          apellidos,
          email,
          password,
          _telefonoCompleto,
          "CLIENTE"
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessClientScreen()),
        );
      }
    } catch (e) {
      _mostrarSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.redAccent);
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                // Botón Atrás
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // ── LOGO SUPERIOR ──
                Center(
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
                    ),
                    child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover)),
                  ),
                ),

                const SizedBox(height: 30),

                // ── TÍTULOS ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text("Regístrate ", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text("/ Login", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Únete a nuestra comunidad hoy mismo", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),

                const SizedBox(height: 35),

                // ── CAMPOS DE REGISTRO ──

                _buildGlassCardField(
                    label: "Nombre",
                    hint: "Tu nombre",
                    controller: _nombreController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words
                ),
                const SizedBox(height: 15),


                _buildGlassCardField(
                    label: "Apellidos",
                    hint: "Tus apellidos",
                    controller: _apellidosController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words
                ),
                const SizedBox(height: 15),

                _buildGlassCardField(
                    label: "Email",
                    hint: "tu@email.com",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress
                ),
                const SizedBox(height: 15),

                // CAMPO DE TELÉFONO CON BANDERAS
                _buildGlassPhoneField(),
                const SizedBox(height: 15),

                _buildGlassCardField(
                    label: "Contraseña",
                    hint: "Crea una clave",
                    controller: _passwordController,
                    isPassword: true
                ),
                const SizedBox(height: 15),

                _buildGlassCardField(
                    label: "Confirmar Contraseña",
                    hint: "Repite tu clave",
                    controller: _confirmPasswordController,
                    isPassword: true
                ),

                const SizedBox(height: 25),

                // Términos y Condiciones
                Row(
                  children: [
                    Checkbox(
                      value: _aceptaTerminos,
                      activeColor: vibrantPurple,
                      side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                      onChanged: (bool? value) => setState(() => _aceptaTerminos = value ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        "Acepto los términos y condiciones de uso.",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ── BOTÓN PRINCIPAL ──
                _buildGlowingVibrantButton("Crear Cuenta", _procesarRegistro),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET: Campo de texto normal de cristal
  Widget _buildGlassCardField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: accentLilac, fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 5),
              TextField(
                controller: controller,
                obscureText: isPassword,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Campo de Teléfono
  Widget _buildGlassPhoneField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Teléfono", style: TextStyle(color: accentLilac, fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 5),
              IntlPhoneField(
                languageCode: "es",
                dropdownTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
                dropdownIconPosition: IconPosition.trailing,
                dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                initialCountryCode: 'ES',
                disableLengthCheck: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Ej: 600 123 456",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counterText: "",
                  isDense: true,
                ),
                onChanged: (phone) {
                  _telefonoCompleto = phone.completeNumber;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Botón brillante
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