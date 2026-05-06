import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class MiBarberiaScreen extends StatefulWidget {
  final int idUsuarioBarbero;

  const MiBarberiaScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<MiBarberiaScreen> createState() => _MiBarberiaScreenState();
}

class _MiBarberiaScreenState extends State<MiBarberiaScreen> {
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

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
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white,
                          child: Icon(Icons.content_cut, color: mainColor, size: 36),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Text(
                "Mi Barbería",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),

              const SizedBox(height: 20),

              // ── TARJETA PRINCIPAL ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // Cabecera degradada
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF381483), Color(0xFF2962FF)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
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
                                        const Icon(Icons.location_on_rounded, size: 13, color: Colors.white60),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            _zonaController.text.isEmpty ? "" : _zonaController.text,
                                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                                child: const Text(
                                  "Solo lectura",
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Contenido
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            child: Column(
                              children: [
                                // Banner info
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accentColor.withOpacity(0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: accentColor, size: 20),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          "Para modificar estos datos contacta con el administrador.",
                                          style: TextStyle(fontSize: 13, color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildInfoCard(
                                  icon: Icons.storefront_rounded,
                                  label: "Nombre del Local",
                                  controller: _nombreController,
                                  iconColor: accentColor,
                                ),
                                _buildInfoCard(
                                  icon: Icons.location_on_rounded,
                                  label: "Dirección Completa",
                                  controller: _direccionController,
                                  iconColor: const Color(0xFFFF6B35),
                                ),
                                _buildInfoCard(
                                  icon: Icons.map_rounded,
                                  label: "Zona o Ciudad",
                                  controller: _zonaController,
                                  iconColor: accentBlue,
                                ),
                                _buildInfoCard(
                                  icon: Icons.schedule_rounded,
                                  label: "Horario Comercial",
                                  controller: _horarioController,
                                  iconColor: Colors.green,
                                ),
                                _buildInfoCard(
                                  icon: Icons.content_cut_rounded,
                                  label: "Descripción / Estilo",
                                  controller: _descripcionController,
                                  iconColor: mainColor,
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

              const SizedBox(height: 12),

              // ── NAV BAR ──
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                          child: Icon(Icons.home_rounded, color: Colors.white60, size: 26),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0x30FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                        child: Icon(Icons.settings_rounded, color: Colors.white60, size: 26),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(color: iconColor.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(
                  controller.text.isEmpty ? "—" : controller.text,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}