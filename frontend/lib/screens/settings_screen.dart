import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final int idCliente;

  const SettingsScreen({super.key, required this.idCliente});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Colores corporativos
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  final Color accentLilac = const Color(0xFFB388FF);

  // --- LÓGICA PARA ENVIAR CORREO DE ERROR ---
  Future<void> _enviarReporteError() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bookcut2026@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Reporte de Error - BookCut App',
        'body': 'Hola equipo de BookCut, he detectado el siguiente problema: \n\n[Describe aquí el error...]',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'No se pudo abrir la app de correo';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró una aplicación de correo instalada")),
      );
    }
  }

  // Utilidad para formatear correctamente los espacios y símbolos en la URL del correo
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // --- TEXTOS LEGALES ---
  final String _textoPrivacidad = """
1. Recopilación de Datos
Recopilamos información básica como su nombre, correo electrónico y teléfono para gestionar sus reservas.

2. Uso de la Información
Sus datos se utilizan exclusivamente para coordinar sus citas y enviarle notificaciones.

3. Protección
No compartimos sus datos con terceros sin su consentimiento.

4. Derechos
Puede eliminar su cuenta y datos definitivamente desde esta pantalla.
""";

  final String _textoTerminos = """
1. Uso de la Plataforma
Se compromete a proporcionar información veraz y hacer un uso responsable del sistema.

2. Reservas y Cancelaciones
Cancele con antelación si no puede asistir por respeto al profesional.

3. Responsabilidad
La calidad del servicio de barbería es responsabilidad exclusiva del local o profesional.
""";

  void _mostrarDocumentoLegal(String titulo, String contenido) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              padding: const EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            titulo,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: accentLilac)
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Text(
                          contenido,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 15,
                            height: 1.6,
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
      },
    );
  }

  void _mostrarDialogoEliminarCuenta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A1B44),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5)
          ),
          contentPadding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("¿Eliminar cuenta?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                "Esta acción es irreversible. Perderás todo tu historial de citas y datos personales.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _ejecutarBorrado();
                      },
                      child: const Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuenta eliminada"), backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.8),
                radius: 1.5,
                colors: [pinkAccent, deepPurple],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text("Ajustes", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ZONA CENTRAL
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: 40,
                          child: Container(
                            width: 280, height: 280,
                            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)]),
                            child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.5))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //  CABECERA MÁS VIBRANTE
                                      Text("GENERAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: pinkAccent, letterSpacing: 1.5)),
                                      const SizedBox(height: 20),

                                      //  ICONO NARANJA VIVO
                                      _buildGlassOptionItem(
                                          icon: Icons.bug_report_rounded,
                                          title: "Reportar error",
                                          subtitle: "Envíanos un correo con tu problema",
                                          iconColor: Colors.orangeAccent,
                                          onTap: _enviarReporteError
                                      ),
                                      _buildDivider(),

                                      //  ICONO CYAN VIVO
                                      _buildGlassOptionItem(
                                          icon: Icons.privacy_tip_rounded,
                                          title: "Política de privacidad",
                                          iconColor: Colors.cyanAccent,
                                          onTap: () => _mostrarDocumentoLegal("Política de Privacidad", _textoPrivacidad)
                                      ),
                                      _buildDivider(),

                                      //  ICONO VERDE VIVO
                                      _buildGlassOptionItem(
                                          icon: Icons.description_rounded,
                                          title: "Términos del servicio",
                                          iconColor: Colors.greenAccent,
                                          onTap: () => _mostrarDocumentoLegal("Términos del Servicio", _textoTerminos)
                                      ),

                                      const SizedBox(height: 35),

                                      //  CABECERA MÁS VIBRANTE
                                      Text("CUENTA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: pinkAccent, letterSpacing: 1.5)),
                                      const SizedBox(height: 20),

                                      //  ICONO BLANCO PURO
                                      _buildGlassOptionItem(
                                          icon: Icons.logout_rounded,
                                          title: "Cerrar sesión",
                                          subtitle: "Salir de tu cuenta actual de forma segura",
                                          iconColor: Colors.white,
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                                          }
                                      ),
                                      _buildDivider(),

                                      //  ICONO ROJO VIVO
                                      _buildGlassOptionItem(
                                        icon: Icons.delete_forever_rounded,
                                        title: "Eliminar cuenta",
                                        subtitle: "Borrar mis datos definitivamente",
                                        iconColor: Colors.redAccent,
                                        titleColor: Colors.redAccent,
                                        onTap: _mostrarDialogoEliminarCuenta,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // FOOTER
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text("DARKMATTER", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4.0)),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.5), child: Center(child: CircularProgressIndicator(color: accentLilac))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1));

  //  WIDGET ACTUALIZADO PARA HACER BRILLAR LOS COLORES VIVOS
  Widget _buildGlassOptionItem({required IconData icon, required String title, String? subtitle, Color? titleColor, Color? iconColor, required VoidCallback onTap}) {
    final Color effectiveIconColor = iconColor ?? accentLilac; // Por defecto usa el lila si no se le pasa nada

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.15), // Fondo con el mismo color vivo pero transparente
                shape: BoxShape.circle,
                border: Border.all(color: effectiveIconColor.withOpacity(0.4), width: 1), // Borde sutil brillante
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, color: titleColor ?? Colors.white, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)))]
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3), size: 24),
          ],
        ),
      ),
    );
  }
}