import 'package:flutter/material.dart';
import 'barber_requested_appointments_screen.dart';
// REUTILIZABLE: Menú inferior (activo para 'Inicio')
class BarberBottomNavBar extends StatelessWidget {
  const BarberBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el color rosa/magenta de la app como acento
    final accentColor = const Color(0xFFE96D71);
    final iconColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Icono Inicio (Activo)
          IconButton(
            icon: Icon(Icons.home, color: accentColor, size: 34),
            onPressed: () {},
          ),
          // Icono Calendario
          IconButton(
            icon: Stack(
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
          // Icono Ayuda
          IconButton(
            icon: Icon(Icons.help_outline, color: iconColor, size: 32),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class BarberHomeScreen extends StatefulWidget {
  // DATOS DINÁMICOS: Vendrían tras el registro
  final String barberName;
  final String shopName;

  const BarberHomeScreen({
    super.key,
    required this.barberName,
    required this.shopName,
  });

  @override
  State<BarberHomeScreen> createState() => _BarberHomeScreenState();
}

class _BarberHomeScreenState extends State<BarberHomeScreen> {
  // Color morado oscuro de la app
  final mainColor = const Color(0xFF381483);
  // Color rosa/magenta de acento
  final accentColor = const Color(0xFFE96D71);
  // Color de fondo lavanda pálido para la tarjeta
  final cardBgColor = const Color(0xFFE5DDFD);

  // Widget reutilizable para el logotipo circular
  Widget _buildLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12, width: 1.5),
        image: const DecorationImage(
          image: AssetImage('assets/logo.png'), // Recordatorio: Asegúrate de declarar el asset en pubspec.yaml
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget reutilizable para el avatar con el borde degradado (simplificado en color sólido para este paso)
  Widget _buildAvatar(double size, double borderWidth) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accentColor, accentColor], // Aquí iría el gradiente real rosa/magenta
        ),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.black54, // Color de fondo si no hay imagen
        child: Icon(Icons.person, color: Colors.white, size: size * 0.6),
      ),
    );
  }

  // Widget reutilizable para construir los botones interiores con icono y flecha
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
            // Icono descriptivo del menú
            Icon(icon, size: 22, color: mainColor),
            const SizedBox(width: 15),
            // Texto del menú (expandido y alineado a la izquierda)
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
            // Flecha indicadora a la derecha
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
            colors: [mainColor, mainColor, const Color(0xFF1A0A3D)], // Violeta a morado más oscuro
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER (Perfil y Logotipo) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // Pequeño icono de perfil a la izquierda
                    _buildAvatar(45, 1.5),
                    const Spacer(), // Empujar logotipo al centro
                    // Logotipo central
                    _buildLogo(),
                    const Spacer(), // Equilibrar espaciado
                    const SizedBox(width: 45), // Espacio para equilibrar el icono de perfil
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // --- TÍTULO DE LA SECCIÓN ---
              const Text(
                "Inicio",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // --- TARJETA DE PERFIL MEJORADA Y MÁS BONITA ---
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
                          // --- INFO DE PERFIL (Avatar, Nombre, Barbería) ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gran avatar de perfil a la izquierda
                              _buildAvatar(100, 2),
                              const SizedBox(width: 20),
                              // Columna de texto dinámico
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    Text(
                                      widget.barberName, // DINÁMICO
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      widget.shopName, // DINÁMICO
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

                          // --- BOTONES DEL MENÚ CON ICONOS ---
                          _buildMenuButton(
                            icon: Icons.pending_actions,
                            text: "Citas Solicitadas",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BarberRequestedAppointmentsScreen()),
                              );
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.check_circle_outline,
                            text: "Citas Aceptadas",
                            onTap: () {
                              // TODO: Navegar a pantalla de citas aceptadas
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.content_cut,
                            text: "Servicios ofrecidos",
                            onTap: () {
                              // TODO: Navegar a pantalla de gestión de servicios
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.leaderboard_outlined,
                            text: "Panel de ingresos",
                            onTap: () {
                              // TODO: Navegar a pantalla de ingresos
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

              // --- MENÚ DE NAVEGACIÓN INFERIOR ---
              const BarberBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}