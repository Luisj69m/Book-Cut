import 'package:flutter/material.dart';
import 'barber_requested_appointments_screen.dart';
import 'barber_accepted_appointments_screen.dart';
import 'settings_screen.dart';
import 'earnings_barber_screen.dart';
import 'services_barber_screen.dart';
// --- MENÚ INFERIOR REUTILIZABLE ---
class BarberBottomNavBar extends StatelessWidget {
  const BarberBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFE96D71);
    const iconColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: accentColor, size: 34),
            onPressed: () {},
          ),
          IconButton(
            icon: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, color: iconColor, size: 30),
                Positioned(
                  top: 10,
                  child: Text(
                    "15",
                    style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: iconColor, size: 32),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class BarberHomeScreen extends StatefulWidget {
  final String barberName;
  final String shopName;
  final int idUsuarioBarbero; // <-- Añadido el ID que viene del Login

  const BarberHomeScreen({
    super.key,
    required this.barberName,
    required this.shopName,
    required this.idUsuarioBarbero, // <-- Obligatorio pasarlo aquí
  });

  @override
  State<BarberHomeScreen> createState() => _BarberHomeScreenState();
}

class _BarberHomeScreenState extends State<BarberHomeScreen> {
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final cardBgColor = const Color(0xFFE5DDFD);

  Widget _buildLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12, width: 1.5),
        image: const DecorationImage(
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAvatar(double size, double borderWidth) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accentColor, accentColor],
        ),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        child: Icon(Icons.person, color: Colors.white, size: size * 0.6),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 22, color: mainColor),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.black26),
          ],
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildAvatar(45, 1.5),
                    const Spacer(),
                    _buildLogo(),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white70, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              const Text(
                "Inicio",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAvatar(100, 2),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    Text(
                                      widget.barberName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.shopName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 35),

                          // --- BOTÓN CITAS SOLICITADAS (CORREGIDO) ---
                          _buildMenuButton(
                            icon: Icons.pending_actions,
                            text: "Citas Solicitadas",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BarberRequestedAppointmentsScreen( // SIN CONST
                                    idUsuarioBarbero: widget.idUsuarioBarbero, // Pasamos el ID
                                  ),
                                ),
                              );
                            },
                          ),

                          // BOTÓN: CITAS ACEPTADAS
                          _buildMenuButton(
                            icon: Icons.check_circle_outline,
                            text: "Citas Aceptadas",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BarberAcceptedAppointmentsScreen( // SIN CONST
                                    idUsuarioBarbero: widget.idUsuarioBarbero, // Pasamos el ID
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildMenuButton(
                            icon: Icons.content_cut,
                            text: "Servicios ofrecidos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicesBarberScreen(),
                                ),
                              );
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.leaderboard_outlined,
                            text: "Panel de ingresos",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EarningsBarberScreen(),
                                ),
                              );
                            },
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const BarberBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}