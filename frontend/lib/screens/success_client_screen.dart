import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importamos el login para volver al inicio

class SuccessClientScreen extends StatelessWidget {
  const SuccessClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Capa del fondo: La imagen con un filtro oscuro
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                // ¡Asegúrate de tener esta imagen en tu carpeta assets!
                image: AssetImage('assets/bg_registro.png'),
                fit: BoxFit.cover,
              ),
            ),
            // Esto le pone una capa negra semitransparente por encima a la foto
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          // 2. Capa de contenido: Los textos y el botón
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),

                  // Texto Principal
                  const Text(
                    "Comienza a descubrir quién\nencuentra tu verdadero estilo.\n¡Reserva ya!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2, // Espaciado entre líneas
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Texto secundario (Itálica)
                  const Text(
                    "Se ha enviado un código de verificación a tu correo\npara confirmar el registro.",
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
                        backgroundColor: Colors.black.withOpacity(0.5), // Fondo negro translúcido
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.white24, width: 1), // Borde sutil
                        ),
                      ),
                      onPressed: () {
                        // Al darle a continuar, borramos el historial de pantallas
                        // y volvemos limpios al Login para que el usuario inicie sesión.
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) =>  LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text("Continuar", style: TextStyle(fontSize: 14)),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Footer DARKMATTER
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