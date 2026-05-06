import 'package:flutter/material.dart';
import '../services/api_service.dart';
// IMPORTANTE: Asegúrate de que esta ruta apunta a tu archivo de Login real
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final int idCliente; // <-- Necesitamos recibir el ID para saber a quién borrar

  const SettingsScreen({super.key, required this.idCliente});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // --- LÓGICA DE BORRADO DE CUENTA ---
  void _mostrarDialogoEliminarCuenta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(25),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 50),
              const SizedBox(height: 15),
              const Text("¿Eliminar cuenta?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Esta acción es irreversible. Perderás todo tu historial de citas y datos personales.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el diálogo
                        _ejecutarBorrado(); // Llama a la función de borrar
                      },
                      child: const Text("Eliminar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _ejecutarBorrado() async {
    setState(() => _isLoading = true);

    bool exito = await _apiService.eliminarCuenta(widget.idCliente);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exito) {
      // ---  LIMPIAR TOKEN  ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Borramos la llave del almacenamiento local
      // ----------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cuenta y datos asociados eliminados correctamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Redirigir al Login y limpiar historial
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al intentar eliminar la cuenta"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF381483),
      body: Stack(
        children: [
          // FONDO Y DISEÑO PRINCIPAL
          Container(
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
                          width: MediaQuery.of(context).size.width * 0.80, // Lo amplié un pelín para que quepa bien el texto
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
                                    print("Abriendo correo...");
                                  }
                              ),
                              const SizedBox(height: 20),
                              _buildOptionItem(
                                  title: "Política de privacidad",
                                  onTap: () {}
                              ),
                              const SizedBox(height: 20),
                              _buildOptionItem(
                                  title: "Términos del servicio",
                                  onTap: () {}
                              ),

                              const SizedBox(height: 15),
                              Divider(color: Colors.grey.shade300, thickness: 1),
                              const SizedBox(height: 15),

                              // --- BOTÓN CERRAR SESIÓN ---
                              _buildOptionItem(
                                  title: "Cerrar sesión",
                                  subtitle: "Salir de tu cuenta actual",
                                  titleColor: Colors.black87, // Lo dejo en negro para no quitar protagonismo al de borrar
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                          (route) => false,
                                    );
                                  }
                              ),

                              const SizedBox(height: 20),

                              // --- BOTÓN ELIMINAR CUENTA ---
                              _buildOptionItem(
                                title: "Eliminar cuenta",
                                subtitle: "Borrar mis datos definitivamente",
                                titleColor: Colors.redAccent.shade700, // Este sí en rojo alerta
                                onTap: _mostrarDialogoEliminarCuenta,
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

          // --- OVERLAY DE CARGA ---
          // Si _isLoading es true, pintamos una capa oscura con la ruedita de carga encima de todo
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // Widget para construir cada texto
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