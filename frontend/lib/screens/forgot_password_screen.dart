import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  // Lógica Paso 1
  Future<void> _solicitarCodigo() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _mostrarSnackBar("Introduce un correo válido", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Intentamos llamar al ApiService
      bool exito = await _apiService.solicitarRecuperacion(email);

      if (exito) {
        _mostrarSnackBar("Código enviado. Revisa la bandeja de entrada del correo.", Colors.green);
        setState(() => _currentStep = 2); // Pasamos al siguiente formulario
      }
    } catch (e) {
      // 🛡️ Si el ApiService lanza un error (como el 403 de Iván), cae aquí
      _mostrarSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      // 🛑 ESTO ES LO IMPORTANTE: Se ejecuta SIEMPRE, apagando la ruedita
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
      _mostrarSnackBar("Código inválido o contraseña muy corta", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    bool exito = await _apiService.confirmarRecuperacion(codigo, nuevaClave);

    setState(() => _isLoading = false);

    if (exito) {
      _mostrarSnackBar("¡Contraseña actualizada con éxito!", Colors.green);
      Navigator.pop(context); // Volvemos al Login
    } else {
      _mostrarSnackBar("Código incorrecto o expirado", Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [Color(0xFFE96D71), Color(0xFF381483)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("Reestablecimiento de contraseña ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 40), // Balance visual
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Icon(Icons.lock_reset, size: 80, color: Colors.white),
              const SizedBox(height: 20),

              // CONTENEDOR BLANCO
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _currentStep == 1 ? _buildPaso1() : _buildPaso2(),
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

  // INTERFAZ PASO 1: Pedir Correo
  Widget _buildPaso1() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("¿Olvidaste tu contraseña?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF381483))),
        const SizedBox(height: 10),
        Text("Introduce tu correo electrónico y te enviaremos un código de 6 dígitos para restablecerla.", style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
        const SizedBox(height: 30),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF381483)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF381483), width: 2)),
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF), // accentBlue
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: _isLoading ? null : _solicitarCodigo,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Enviar código", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  // INTERFAZ PASO 2: Introducir Código y Nueva Contraseña
  Widget _buildPaso2() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Introduce el código", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF381483))),
        const SizedBox(height: 10),
        Text("Hemos generado un código para ${_emailController.text}. Revisa la consola o tu bandeja.", style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
        const SizedBox(height: 30),

        // Input Código
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: "",
            hintText: "000000",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF381483), width: 2)),
          ),
        ),
        const SizedBox(height: 20),

        // Input Nueva Contraseña
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Nueva contraseña",
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF381483)),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF381483), width: 2)),
          ),
        ),
        const SizedBox(height: 40),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE96D71), // accentPink
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: _isLoading ? null : _cambiarContrasena,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Actualizar contraseña", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),

        // Botón para volver atrás por si se equivocaron de correo
        Center(
          child: TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text("Usar otro correo electrónico"),
          ),
        )
      ],
    );
  }
}