import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';
import 'register_client_screen.dart';
import 'home_client_screen.dart';
import 'barber_home_screen.dart'; // Importamos la pantalla del barbero

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variable para controlar si estamos esperando respuesta del servidor
  bool _isLoading = false;

  // Esta es la función central que habla con el Backend
  Future<void> _procesarLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // 1. Validamos que no envíen campos vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    // Encendemos la ruedita de carga
    setState(() { _isLoading = true; });

    try {
      // 2. Llamamos al backend
      final usuario = await ApiService().login(email, password);

      // 3. Verificamos el rol que nos ha devuelto Java
      if (usuario['rolUsuario'] == 'BARBERO') {
        print("¡Es un barbero! ID: ${usuario['idUsuario']}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Bienvenido Barbero!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );

        // --- NAVEGACIÓN AL HOME DEL BARBERO ---
        // Intentamos sacar el nombre de la base de datos (usuario['nombre']).
        // Si Iván no lo envía en el login, usamos "Luis Jose" por defecto para que no falle.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BarberHomeScreen(
              barberName: usuario['nombre'] ?? "Luis Jose",
              shopName: "La Rodola BarberShop", // Esto lo dejamos fijo por ahora
            ),
          ),
        );

      } else {
        print("¡Es un cliente! ID: ${usuario['idUsuario']}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Bienvenido Cliente!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeClientScreen()),
        );
      }

    } catch (e) {
      // 4. Si nos devuelve error (ej. contraseña mal), lo mostramos en rojo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Apagamos la ruedita de carga pase lo que pase
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              flex: 4,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
                      ]
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 6,
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
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "info@example.com",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                      const SizedBox(height: 20),

                      const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "***************",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                      const SizedBox(height: 35),

                      // Botón Iniciar Sesión (Cliente)
                      _buildGlowingButton("Iniciar Sesión", _procesarLogin),

                      const SizedBox(height: 20),

                      // Botón Iniciar Sesión (Barbero)
                      _buildGlowingButton("Iniciar sesion como Barbero", _procesarLogin),

                      const SizedBox(height: 30),

                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            "¿Has olvidado la contraseña?",
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterClientScreen()),
                            );
                          },
                          child: Text(
                            "No estas registrado? Registrate!",
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ),
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

  // Widget del botón.
  Widget _buildGlowingButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            )
          ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        )
            : Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}