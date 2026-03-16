import 'package:flutter/material.dart';
import 'calendar_client_screen.dart';
import 'appointments_screen.dart';
import 'settings_screen.dart';
import 'profile_client_screen.dart'; // Importamos la pantalla de perfil

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
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
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // --- AVATAR CON NAVEGACIÓN AL PERFIL ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          // NAVEGACIÓN A LA PANTALLA DE PERFIL
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileClientScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.pinkAccent.withOpacity(0.5), width: 2),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.black87,
                            radius: 20,
                            child: Icon(Icons.person, color: Colors.white54, size: 25),
                          ),
                        ),
                      ),
                    ),

                    // --- LOGO CENTRAL ---
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
                          ]
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                "BOOK & CUT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 4.0,
                ),
              ),

              const SizedBox(height: 20),

              // --- BUSCADOR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar barberías",
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: const Icon(Icons.search, color: Colors.black87),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- TARJETA BLANCA DE BARBERÍAS ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Barberías", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(height: 5),
                              Text("Seleccione la barbería en la que desea reservar", style: TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),

                        const Divider(color: Colors.black12, thickness: 1, indent: 20, endIndent: 20),

                        // --- LISTA DE BARBERÍAS ---
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(top: 0),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildBarberiaItem(
                                  1,
                                  "La Rodola",
                                  "Lunes - Sábado",
                                  "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60"
                              ),
                              _buildBarberiaItem(
                                  2,
                                  "Peine Jr",
                                  "Lunes - Sábado",
                                  "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop&q=60"
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- MENÚ INFERIOR ---
              _buildBottomNavBar(context, activeIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET DE LA BARBERÍA ---
  Widget _buildBarberiaItem(int id, String nombre, String horario, String imageUrl) {
    return InkWell(
      onTap: () {
        // Navegación al calendario pasando los datos
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarClientScreen(
              barberiaId: id,
              barberiaNombre: nombre,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 65, height: 65, color: Colors.grey.shade200,
                  child: const Icon(Icons.storefront, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text("5.0", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      const SizedBox(width: 8),
                      Text(horario, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // --- BARRA INFERIOR ---
  Widget _buildBottomNavBar(BuildContext context, {required int activeIndex}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: activeIndex == 0 ? const Color(0xFF2962FF) : Colors.white, size: 32),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.receipt_long_outlined, color: activeIndex == 1 ? const Color(0xFF2962FF) : Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, color: activeIndex == 2 ? const Color(0xFF2962FF) : Colors.white, size: 30),
                const Positioned(top: 10, child: Text("15", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una barbería primero')));
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: activeIndex == 3 ? const Color(0xFF2962FF) : Colors.white, size: 32),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}