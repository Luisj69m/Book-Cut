import 'package:flutter/material.dart';
import 'calendar_client_screen.dart';
import 'appointments_screen.dart';
import 'settings_screen.dart';
import 'profile_client_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/api_config.dart';

class HomeClientScreen extends StatefulWidget {
  final int idUsuarioCliente;
  const HomeClientScreen({super.key, required this.idUsuarioCliente});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? _fotoUrlServidor;

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil();
  }

  Future<void> _cargarFotoPerfil() async {
    try {
      final datos = await _apiService.getPerfil();
      final nombreArchivo = datos['urlFotoPerfil'];
      if (nombreArchivo != null && nombreArchivo.isNotEmpty) {
        setState(() {
          _fotoUrlServidor = "${ApiConfig.baseUrl}/perfil/imagen/$nombreArchivo";
        });
      }
    } catch (e) {
      print("Error cargando la foto en la Home: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // 👇 ESTO ES CLAVE: Permite que el fondo blanco fluya POR DEBAJO de la barra flotante
      extendBody: true,

      // 👇 NUEVA BARRA DE NAVEGACIÓN FLOTANTE
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          child: _buildFloatingNavBar(context, activeIndex: 0),
        ),
      ),

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
        // Desactivamos el bottom del SafeArea para que el blanco llegue hasta el final de la pantalla
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER LIMPIO (SOLO LOGO) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
                        ]
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
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
                    hintText: "Buscar barberías...",
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- CONTENEDOR DE BARBERÍAS ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))
                      ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Barberías Destacadas",
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.black87)
                                ),
                                const SizedBox(height: 4),
                                Text("Encuentra tu estilo ideal",
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600)
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE96D71).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.tune, color: Color(0xFFE96D71), size: 20),
                            )
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          // 👇 Le damos bastante padding abajo para que la última tarjeta no quede tapada por la barra flotante
                          padding: const EdgeInsets.only(top: 5, bottom: 100),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildBarberiaCard(
                                1,
                                "La Rodola",
                                "Mérida, Centro",
                                "Lunes - Sábado",
                                "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60",
                                5.0
                            ),
                            _buildBarberiaCard(
                                2,
                                "Peine Jr",
                                "Mérida, Nueva Ciudad",
                                "Lunes - Sábado",
                                "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop&q=60",
                                4.8
                            ),
                          ],
                        ),
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

  // --- TARJETA DE BARBERÍA ---
  Widget _buildBarberiaCard(int id, String nombre, String ubicacion, String horario, String imageUrl, double rating) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.grey.shade50,
          splashColor: const Color(0xFF381483).withOpacity(0.1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarClientScreen(
                  barberiaId: id,
                  barberiaNombre: nombre,
                  idCliente: widget.idUsuarioCliente,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 75, height: 75, color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(rating.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey.shade500, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(ubicacion, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: Colors.grey.shade500, size: 14),
                              const SizedBox(width: 4),
                              Text(horario, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF381483).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Reservar",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF381483),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- NUEVA BARRA FLOTANTE (ESTILO PÍLDORA) ---
  Widget _buildFloatingNavBar(BuildContext context, {required int activeIndex}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF381483), // El morado oscuro de tu app
          borderRadius: BorderRadius.circular(40), // Bordes súper redondeados
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF381483).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 0. HOME
          _buildNavItem(Icons.home_rounded, 0, activeIndex, () {}),

          // 1. CITAS
          _buildNavItem(Icons.receipt_long_rounded, 1, activeIndex, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppointmentsScreen(idUsuarioCliente: widget.idUsuarioCliente,)),
            );
          }),

          // 2. PERFIL (Tu foto dinámica)
          _buildProfileNavItem(2, activeIndex),

          // 3. AJUSTES
          _buildNavItem(Icons.settings_rounded, 3, activeIndex, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }),
        ],
      ),
    );
  }

  // --- WIDGET PARA LOS ICONOS NORMALES (CON ANIMACIÓN) ---
  Widget _buildNavItem(IconData icon, int index, int activeIndex, VoidCallback onTap) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Si está seleccionado, le ponemos un fondo blanco translúcido
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
          size: 26,
        ),
      ),
    );
  }

  // --- WIDGET PARA LA FOTO DE PERFIL (CON ANIMACIÓN) ---
  Widget _buildProfileNavItem(int index, int activeIndex) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileClientScreen()),
        ).then((_) {
          _cargarFotoPerfil(); // Recarga la foto al volver
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(4), // Actúa como el anillo de selección
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.white70,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: _fotoUrlServidor != null
                ? Image.network(
              _fotoUrlServidor!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade400, child: const Icon(Icons.person, color: Colors.white, size: 20)),
            )
                : Container(color: Colors.grey.shade400, child: const Icon(Icons.person, color: Colors.white, size: 20)),
          ),
        ),
      ),
    );
  }
}