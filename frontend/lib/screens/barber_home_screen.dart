import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
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
  // Mantengo tus colores originales intactos
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
      if (correo.isEmpty) return;
      final barberia = await ApiService().getBarberiaAsignada(correo);
      if (barberia != null && mounted) {
        setState(() => _nombreBarberia = barberia['nombre'] ?? widget.shopName);
      }
    } catch (_) {
      if (mounted) setState(() => _nombreBarberia = widget.shopName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Para que el fondo oscuro llegue hasta abajo
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(activeIndex: 0),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Tu degradado morado oscuro original
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, mainColor, const Color(0xFF1A0A3D)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER PREMIUM ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hola,",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.barberName.isNotEmpty ? widget.barberName : "Barbero",
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    // Avatar / Badge Activo
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            widget.barberName.isNotEmpty ? widget.barberName[0].toUpperCase() : "B",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Positioned(
                            bottom: 2, right: 2,
                            child: Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: mainColor, width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: Colors.white.withOpacity(0.5), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _nombreBarberia,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ── BENTO BOX GRID ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  child: Column(
                    children: [
                      // 1. BANNER PRINCIPAL (Ancho Completo)
                      _buildBentoBanner(
                        title: "Citas Solicitadas",
                        subtitle: "Nuevas reservas pendientes de revisión",
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFFF9800), // Naranja alerta
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BarberRequestedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                        )),
                      ),

                      const SizedBox(height: 12),

                      // 2. FILA DE CUADRADOS (Mitad y Mitad)
                      Row(
                        children: [
                          _buildBentoSquare(
                            title: "Citas Aceptadas",
                            subtitle: "Tu agenda del día",
                            icon: Icons.check_circle_rounded,
                            color: Colors.greenAccent,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => BarberAcceptedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                            )),
                          ),
                          _buildBentoSquare(
                            title: "Ingresos",
                            subtitle: "Panel financiero",
                            icon: Icons.leaderboard_rounded,
                            color: const Color(0xFF40C4FF), // Cyan claro
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => EarningsBarberScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                            )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 3. OTRA FILA DE CUADRADOS (Mitad y Mitad)
                      Row(
                        children: [
                          _buildBentoSquare(
                            title: "Mi Barbería",
                            subtitle: "Gestión del local",
                            icon: Icons.store_rounded,
                            color: accentColor, // Rosa
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => MiBarberiaScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                            )),
                          ),
                          _buildBentoSquare(
                            title: "Servicios",
                            subtitle: "Precios y oferta",
                            icon: Icons.content_cut_rounded,
                            color: const Color(0xFFB388FF), // Lila
                            onTap: () => Navigator.push(context, MaterialPageRoute(

                              builder: (_) => ServicesBarberScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                            )),
                          ),
                        ],
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

  // --- WIDGET BENTO: BANNER (Horizontal) ---
  Widget _buildBentoBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), // Fondo tintado para dar sensación de alerta/importancia
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BENTO: CUADRADO (Vertical) ---
  Widget _buildBentoSquare({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06), // Mate oscuro elegante
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NAVBAR CRISTALINA ---
  Widget _buildGlassmorphicNavBar({required int activeIndex}) {
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
              _buildNavItem(Icons.home_rounded, 0, activeIndex, () {}),
              _buildNavItem(Icons.calendar_month_rounded, 1, activeIndex, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BarberRequestedAppointmentsScreen(idUsuarioBarbero: widget.idUsuarioBarbero),
                ));
              }),
              _buildNavItem(Icons.settings_rounded, 2, activeIndex, () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SettingsScreen(idCliente: widget.idUsuarioBarbero),
                ));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int activeIndex, VoidCallback onTap) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? accentColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 26),
      ),
    );
  }
}