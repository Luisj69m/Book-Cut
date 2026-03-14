import 'package:flutter/material.dart';
import 'calendar_client_screen.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  // Controlador para el buscador
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evitamos que el teclado empuje los iconos del menú inferior
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
              // --- HEADER (Perfil y Logo) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Icono de perfil a la izquierda
                    Align(
                      alignment: Alignment.centerLeft,
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
                    // Logo en el centro
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 10, offset: const Offset(0, 5))
                          ]
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              // --- TEXTO BOOK & CUT ---
              // Nota: Como en tu diseño tiene un estilo de velocidad, le he puesto una fuente itálica gruesa.
              // Si tenéis una imagen para este texto, podéis cambiar este Text por un Image.asset()
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabecera de la tarjeta
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Barberías", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 5),
                              Text("Seleccione la barbería en la que desea reservar", style: TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),

                        const Divider(color: Colors.black26, thickness: 1, indent: 20, endIndent: 20),

                        // Lista de Barberías (Mockeada según tu diseño)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(top: 0),
                            children: [
                              _buildBarberiaItem("La Rodola", "Lunes - Sábado"),
                              _buildBarberiaItem("Peine Jr", "Lunes - Sábado"),
                              // La línea final
                              const Divider(color: Colors.black26, thickness: 1, indent: 20, endIndent: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- MENÚ INFERIOR (Bottom Navigation) ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Icono Casa
                    IconButton(
                      icon: const Icon(Icons.home_outlined, color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                    // Icono Calendario (con el 15 dentro)
                    IconButton(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 30),
                          Positioned(
                            top: 10,
                            child: Text("15", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CalendarClientScreen()),
                        );
                      },
                    ),
                    // Icono Ayuda
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir cada fila de la lista rápido
  Widget _buildBarberiaItem(String nombre, String horario) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: const Icon(Icons.star_border, color: Colors.amber, size: 28),
      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(horario, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      onTap: () {
        // TODO: Navegar a la pantalla de reservar cita
        print("Has tocado en $nombre");
      },
    );
  }
}