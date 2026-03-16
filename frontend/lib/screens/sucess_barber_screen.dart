import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importamos el login para volver al inicio

class SuccessBarberScreen extends StatelessWidget {
  const SuccessBarberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Capa del fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Puedes usar la misma foto o cambiar el nombre si descargas otra
                image: AssetImage('assets/bg_registro_barbero.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.6), // Filtro oscuro
            ),
          ),

          // 2. Capa de contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Texto Principal adaptado para el barbero
                  const Text(
                    "Lleva tu talento al siguiente nivel.\n¡Empieza a gestionar tus citas!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Texto secundario adaptado (Itálica)
                  const Text(
                    "Se ha enviado un código de verificación a tu correo\npara confirmar el registro de la barbería.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botón Continuar
                  SizedBox(
                    height: 40,
                    width: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white24, width: 1),
                        ),
                      ),
                      onPressed: () {
                        // Volvemos limpios al Login (¡Sin el 'const' problemático!)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text("Continuar", style: TextStyle(fontSize: 14)),
                    ),
                  ),

                  const Spacer(flex: 2),

                  const Text(
                    "DARKMATTER",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}