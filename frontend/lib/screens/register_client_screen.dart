import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_barber_screen.dart';
import 'success_client_screen.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  // Eliminado el _nombreController. Nos quedamos solo con lo que existe en BD.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _aceptaTerminos = false;
  bool _isLoading = false;

  void _procesarRegistro() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 1. Validaciones básicas (sin el nombre)
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // TODO: Aquí llamaremos a ApiService().registrarUsuario(email, password, "CLIENTE")
      print("Registrando Cliente... Email: $email");

      // Simulamos la espera del servidor
      // Llamamos de verdad al backend de Iván
      // Llamamos de verdad al backend de Iván rellenando los huecos vacíos
      await ApiService().registrarUsuario(
          "Usuario", // Nombre por defecto (por si Java lo exige)
          "",        // Apellidos vacíos
          email,     // El email real del campo de texto
          password,  // La contraseña real
          "",        // Teléfono vacío
          "CLIENTE"  // El rol
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessClientScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.redAccent),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [
              Color(0xFFE96D71),
              Color(0xFF381483),
            ],
          ),
        ),
        child: Column(
          children: [
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
                          BoxShadow(color: Colors.black38, blurRadius: 10, offset: const Offset(0, 5))
                        ]
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 8,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Campos de texto (El nombre ya no está)
                      _buildTextField("Email", "info@example.com", _emailController, false, TextInputType.emailAddress),
                      const SizedBox(height: 15),

                      _buildTextField("Contraseña", "***************", _passwordController, true),
                      const SizedBox(height: 15),

                      _buildTextField("Confirmar Contraseña", "***************", _confirmPasswordController, true),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Checkbox(
                            value: _aceptaTerminos,
                            activeColor: Colors.black,
                            onChanged: (bool? value) {
                              setState(() {
                                _aceptaTerminos = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "Acepto los términos y condiciones de uso.",
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      _buildGlowingButton("Registrarse", _procesarRegistro),

                      const SizedBox(height: 15),

                      _buildGlowingButton("Soy Barbero", () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterBarberScreen()),
                        );

                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isPassword, [TextInputType keyboardType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 0),
            )
          ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading && text == "Registrarse"
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}