import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controlador para el campo de texto. Usamos '_emailController'
  // aunque la etiqueta pida "Nombre", porque el hint pide email.
  final TextEditingController _emailController = TextEditingController();

  void _enviarSolicitudCambio() {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce tu email o nombre')),
      );
      return;
    }

    // TODO: Aquí llamarás al ApiService de Iván cuando tenga este endpoint
    print("Solicitando cambio de contraseña para: $email");

    // De momento, simulamos éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Si la cuenta existe, recibirás un email para restablecer la contraseña en: $email'),
        backgroundColor: Colors.green,
      ),
    );

    // Opcional: Volver automáticamente al Login después de 3 segundos
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (mounted) Navigator.pop(context);
    // });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que se encoja el fondo al abrir teclado
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Mismo degradado de fondo que el Login
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
            // Parte superior: Logo centrado
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
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

            // Parte inferior: Contenedor blanco con el formulario (image_4.png)
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
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flecha de atrás (<-)
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            // Cierra esta pantalla y vuelve al Login
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Label: "Nombre" (Como en image_4.png)
                      const Text(
                        "Nombre",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Caja de texto con Hint: "Coloca tu email Aquí" (Como en image_4.png)
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Coloca tu email Aquí",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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

                      const SizedBox(height: 30),

                      // Botón: "Cambiar contraseña" con efecto neón azul
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.6), // Brillo azul
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 0),
                              )
                            ]
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Fondo negro
                            foregroundColor: Colors.white, // Texto blanco
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _enviarSolicitudCambio,
                          child: const Text("Cambiar contraseña", style: TextStyle(fontSize: 15)),
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
}