import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'barber_requested_appointments_screen.dart';
import 'barber_accepted_appointments_screen.dart';
import 'settings_screen.dart';
import 'earnings_barber_screen.dart';
import 'services_barber_screen.dart';
import 'mi_barberia_screen.dart';

class BarberHomeScreen extends StatefulWidget {
  final String barberName;
  final String shopName;
  final int idUsuarioBarbero;

  const BarberHomeScreen({
    super.key,
    required this.barberName,
    required this.shopName,
    required this.idUsuarioBarbero,
  });

  @override
  State<BarberHomeScreen> createState() => _BarberHomeScreenState();
}

class _BarberHomeScreenState extends State<BarberHomeScreen> {
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

  String _nombreBarberia = "Cargando...";

  @override
  void initState() {
    super.initState();
    _cargarNombreBarberia();
  }

  Future<void> _cargarNombreBarberia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString('email_usuario') ?? '';
      print("📧 Correo usado: $correo");
      if (correo.isEmpty) return;
      final barberia = await ApiService().getBarberiaAsignada(correo);
      print("🏪 Barbería recibida: $barberia");
      if (barberia != null && mounted) {
        setState(() => _nombreBarberia = barberia['nombre'] ?? widget.shopName);
      }
    } catch (_) {
      if (mounted) setState(() => _nombreBarberia = widget.shopName);
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final color = iconColor ?? mainColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
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
              // ── HEADER: logo centrado ──
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
                "Panel de Control",
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
                        // Cabecera degradada dentro de la tarjeta
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
                              // Inicial del barbero
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.barberName.isNotEmpty ? widget.barberName[0].toUpperCase() : "B",
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.barberName.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.storefront_rounded, size: 13, color: Colors.white60),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            _nombreBarberia,
                                            style: const TextStyle(color: Colors.white60, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Badge activo
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                                    const SizedBox(width: 5),
                                    const Text("Activo", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lista de opciones
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildMenuButton(
                                icon: Icons.storefront_rounded,
                                text: "Mi Barbería",
                                iconColor: accentColor,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => MiBarberiaScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                                )),
                              ),
                              _buildMenuButton(
                                icon: Icons.pending_actions_rounded,
                                text: "Citas Solicitadas",
                                iconColor: const Color(0xFFFF6B35),
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => BarberRequestedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                                )),
                              ),
                              _buildMenuButton(
                                icon: Icons.check_circle_rounded,
                                text: "Citas Aceptadas",
                                iconColor: Colors.green,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => BarberAcceptedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                                )),
                              ),
                              _buildMenuButton(
                                icon: Icons.content_cut_rounded,
                                text: "Servicios ofrecidos",
                                iconColor: mainColor,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const ServicesBarberScreen(),
                                )),
                              ),
                              _buildMenuButton(
                                icon: Icons.leaderboard_rounded,
                                text: "Panel de ingresos",
                                iconColor: accentBlue,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const EarningsBarberScreen(),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── NAV BAR INFERIOR ──
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
                      _buildNavItem(Icons.home_rounded, active: true, onTap: () {}),
                      _buildNavItem(
                        Icons.calendar_month_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BarberRequestedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                        )),
                      ),
                      _buildNavItem(
                        Icons.settings_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => SettingsScreen(idCliente: widget.idUsuarioBarbero),
                        )),
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

  Widget _buildNavItem(IconData icon, {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }
}