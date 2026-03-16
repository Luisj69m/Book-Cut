import 'package:flutter/material.dart';
// IMPORTANTE: Asegúrate de que esta ruta apunta a tu archivo de Login real
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF381483),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Column(
            children: [
              // --- BOTÓN DE ATRÁS ---
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // --- ZONA CENTRAL (Logo + Tarjeta) ---
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Logo gigante de fondo
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                          ]
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),

                    // 2. Tarjeta blanca flotante
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75, // Ocupa el 75% del ancho
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
                          ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Para que la tarjeta se adapte al contenido
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              "Configuración",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                          ),
                          const SizedBox(height: 10),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          const SizedBox(height: 10),

                          // Opciones
                          _buildOptionItem(
                              title: "Reportar error",
                              subtitle: "Envia un correo para ver tu problema",
                              onTap: () {
                                // TODO: Lógica para abrir la app de correo
                                print("Abriendo correo...");
                              }
                          ),
                          const SizedBox(height: 20),
                          _buildOptionItem(
                              title: "Política de privacidad",
                              onTap: () {
                                // TODO: Lógica para abrir URL
                              }
                          ),
                          const SizedBox(height: 20),
                          _buildOptionItem(
                              title: "Términos del servicio",
                              onTap: () {
                                // TODO: Lógica para abrir URL
                              }
                          ),

                          const SizedBox(height: 15),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          const SizedBox(height: 15),

                          // --- BOTÓN CERRAR SESIÓN ---
                          _buildOptionItem(
                              title: "Cerrar sesión",
                              subtitle: "Salir de tu cuenta actual",
                              titleColor: Colors.redAccent.shade700, // Lo ponemos en rojo para destacar
                              onTap: () {
                                // Navigator.pushAndRemoveUntil borra el historial de navegación
                                // para que no puedan darle "atrás" y volver a entrar sin loguearse.
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false, // Esto es lo que destruye las pantallas anteriores
                                );
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- FOOTER (Firma) ---
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "DARKMATTER",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir cada texto de forma limpia.
  // Ahora acepta 'titleColor' por si queremos cambiar el color del título.
  Widget _buildOptionItem({required String title, String? subtitle, Color? titleColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: titleColor ?? Colors.black87, fontWeight: titleColor != null ? FontWeight.bold : FontWeight.normal)),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ]
          ],
        ),
      ),
    );
  }
}