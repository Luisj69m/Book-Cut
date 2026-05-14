import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'settings_screen.dart'; // Asegúrate de importarlo para la navbar

class MiBarberiaScreen extends StatefulWidget {
  final int idUsuarioBarbero;

  const MiBarberiaScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<MiBarberiaScreen> createState() => _MiBarberiaScreenState();
}

class _MiBarberiaScreenState extends State<MiBarberiaScreen> {
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Colores corporativos (Paleta Dark Mode)
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);
  final accentLilac = const Color(0xFFB388FF);

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _zonaController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosBarberia();
  }

  Future<void> _cargarDatosBarberia() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString('email_usuario') ?? '';
      if (correo.isNotEmpty) {
        final datos = await _apiService.getBarberiaAsignada(correo);
        if (datos != null && mounted) {
          setState(() {
            _nombreController.text = datos['nombre'] ?? 'Sin nombre';
            _direccionController.text = datos['direccionCompleta'] ?? datos['direccion'] ?? 'Sin dirección';
            _zonaController.text = datos['zona'] ?? 'Sin zona';
            _horarioController.text = datos['horario'] ?? 'Sin horario';
            _descripcionController.text = datos['descripcion'] ?? 'Sin descripción';
          });
        }
      }
    } catch (e) {
      print("Error cargando barbería: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, mainColor, const Color(0xFF1A0A3D)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
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
                    const Text("Mi Barbería", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TARJETA DE CRISTAL PRINCIPAL ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            // Cabecera del contenedor (Datos rápidos)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: accentColor, width: 1.5),
                                        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10)]
                                    ),
                                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _nombreController.text.isEmpty ? "Cargando..." : _nombreController.text,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_rounded, size: 13, color: Colors.white.withOpacity(0.5)),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                _zonaController.text.isEmpty ? "" : _zonaController.text,
                                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Badge "Solo lectura"
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                    ),
                                    child: const Text(
                                      "Solo lectura",
                                      style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Contenido (Lista de datos)
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // Espacio inferior para la navbar
                                child: Column(
                                  children: [
                                    // Banner info premium
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline_rounded, color: Colors.blueAccent, size: 22),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              "Para modificar estos datos, por favor, ponte en contacto con el administrador de la plataforma.",
                                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8), height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _buildGlassInfoCard(
                                      icon: Icons.storefront_rounded,
                                      label: "Nombre del Local",
                                      controller: _nombreController,
                                      iconColor: accentColor,
                                    ),
                                    _buildGlassInfoCard(
                                      icon: Icons.location_on_rounded,
                                      label: "Dirección Completa",
                                      controller: _direccionController,
                                      iconColor: const Color(0xFFFF9800), // Naranja vivo
                                    ),
                                    _buildGlassInfoCard(
                                      icon: Icons.map_rounded,
                                      label: "Zona o Ciudad",
                                      controller: _zonaController,
                                      iconColor: accentBlue,
                                    ),
                                    _buildGlassInfoCard(
                                      icon: Icons.schedule_rounded,
                                      label: "Horario Comercial",
                                      controller: _horarioController,
                                      iconColor: Colors.greenAccent, // Verde neón
                                    ),
                                    _buildGlassInfoCard(
                                      icon: Icons.content_cut_rounded,
                                      label: "Descripción / Estilo",
                                      controller: _descripcionController,
                                      iconColor: accentLilac, // Lila
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: TARJETA DE INFORMACIÓN DE CRISTAL ---
  Widget _buildGlassInfoCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Cristal muy sutil
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withOpacity(0.4), width: 1),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))),
                const SizedBox(height: 4),
                Text(
                  controller.text.isEmpty ? "—" : controller.text,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- EFECTO CRISTAL EN LA NAVBAR ---
  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, false, () => Navigator.pop(context)),
              _buildNavItem(Icons.storefront_rounded, true, () {}), // Marcado activo
              _buildNavItem(Icons.settings_rounded, false, () {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => SettingsScreen(idCliente: widget.idUsuarioBarbero),
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? accentColor.withOpacity(0.2) : Colors.transparent, // Resalte rosa sutil
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? accentColor : Colors.white70, size: 26),
      ),
    );
  }
}