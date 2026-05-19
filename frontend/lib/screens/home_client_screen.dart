import 'dart:ui';
import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'settings_screen.dart';
import 'profile_client_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/api_config.dart';
import 'services_client_screen.dart';

class HomeClientScreen extends StatefulWidget {
  final int idUsuarioCliente;
  const HomeClientScreen({super.key, required this.idUsuarioCliente});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen> {
  final ApiService _apiService = ApiService();

  String? _fotoUrlServidor;
  String? _userName;

  // VARIABLES PARA LAS BARBERÍAS REALES
  List<dynamic> _barberias = [];
  bool _isLoadingBarberias = true;
  int _activeCategoryIndex = 0;

  // Categorías
  final List<String> _categories = ["Todos", "Cortes", "Barba", "Color", "Tratamientos"];

  // NUESTRA PISCINA DE FOTOS PREMIUM DE BARBERÍAS
  final List<String> _fotosAleatorias = [
    "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60",
    "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop&q=60",
    "https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=500&auto=format&fit=crop&q=60",
    "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop&q=60",
    "https://images.unsplash.com/photo-1512496015851-a1fbaf692a9f?w=500&auto=format&fit=crop&q=60"
  ];

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil();
    _cargarBarberias();
  }

  Future<void> _cargarFotoPerfil() async {
    try {
      final datos = await _apiService.getPerfil();
      final nombreArchivo = datos['urlFotoPerfil'];
      final nombre = datos['nombre'];

      if (mounted) {
        setState(() {
          _fotoUrlServidor = nombreArchivo;
          _userName = nombre ?? 'Usuario';
        });
      }
    } catch (e) {
      print("Error cargando la foto en la Home: $e");
    }
  }

  Future<void> _cargarBarberias() async {
    setState(() => _isLoadingBarberias = true);
    try {
      final datos = await _apiService.getTodasLasBarberias();
      if (mounted) {
        setState(() {
          _barberias = datos;
          _isLoadingBarberias = false;
        });
      }
    } catch (e) {
      print("Error obteniendo barberías: $e");
      if (mounted) {
        setState(() => _isLoadingBarberias = false);
      }
    }
  }

  String _obtenerImagenBarberia(dynamic barberia, int id) {
    final String urlBD = barberia['urlImagen'] ?? '';
    if (urlBD.isNotEmpty) {
      return urlBD;
    }
    return _fotosAleatorias[id % _fotosAleatorias.length];
  }

  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color accentLilac = const Color(0xFFB388FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
          child: _buildGlassmorphicNavBar(activeIndex: 0),
        ),
      ),
      body: Container(
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
          bottom: false,
          child: _isLoadingBarberias
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
            onRefresh: _cargarBarberias,
            color: pinkAccent,
            backgroundColor: deepPurple,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER CON PERFIL CLICABLE ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                      child: GestureDetector(
                        // ✅ AL TOCAR LA FOTO O EL NOMBRE, VAMOS AL PERFIL
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileClientScreen()),
                          ).then((_) => _cargarFotoPerfil()); // Refresca la foto al volver
                        },
                        child: Container(
                          color: Colors.transparent, // Área clicable completa
                          child: Row(
                            children: [
                              _buildProfilePictureView(),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bienvenido,", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                  Text(_userName ?? 'Usuario', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- BUSCADOR DESPLEGABLE (AUTOCOMPLETE) ---
                    _buildSearchDropdownView(),
                    const SizedBox(height: 25),

                    // --- TARJETA HERO (Siempre se muestra la primera de la BD) ---
                    if (_barberias.isNotEmpty)
                      _buildHeroCard(_barberias[0]),

                    const SizedBox(height: 25),

                    // --- CATEGORÍAS ---
                    _buildCategoriesChipsView(),
                    const SizedBox(height: 25),

                    // --- TARJETAS CUADRADAS HORIZONTALES ---
                    if (_barberias.length > 1)
                      _buildHorizontalSquareCards(),

                    // --- LISTA VERTICAL FINAL ---
                    if (_barberias.length > 3) ...[
                      const SizedBox(height: 30),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("Más Opciones", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      _buildVerticalList(),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET DE BUSCADOR CON DESPLEGABLE (AUTOCOMPLETE) ---
  Widget _buildSearchDropdownView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Autocomplete<Map<String, dynamic>>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<Map<String, dynamic>>.empty();
          }
          final query = textEditingValue.text.toLowerCase();

          return _barberias.where((barberia) {
            final nombre = (barberia['nombre'] ?? '').toLowerCase();
            final zona = (barberia['zona'] ?? '').toLowerCase();
            return nombre.contains(query) || zona.contains(query);
          }).map((item) => Map<String, dynamic>.from(item));
        },
        displayStringForOption: (Map<String, dynamic> option) => option['nombre'] ?? '',
        onSelected: (Map<String, dynamic> seleccion) {
          final int id = seleccion['id'] ?? seleccion['idBarberia'] ?? 0;
          final String imageUrl = _obtenerImagenBarberia(seleccion, id);
          _navegarABarberia(seleccion, imageUrl);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Buscar barbería, especialista...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.only(top: 10),
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: accentLilac.withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(Icons.storefront_rounded, color: accentLilac, size: 20),
                          ),
                          title: Text(
                            option['nombre'] ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            option['zona'] ?? '',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                          ),
                          trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.3)),
                          onTap: () {
                            onSelected(option);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- RESTO DE WIDGETS ---

  Widget _buildHeroCard(dynamic barberia) {
    final int id = barberia['id'] ?? barberia['idBarberia'] ?? 0;
    final String nombre = barberia['nombre'] ?? 'Sin nombre';
    final String ubicacion = barberia['direccionCompleta'] ?? barberia['direccion'] ?? 'Ubicación desconocida';
    final String imageUrl = _obtenerImagenBarberia(barberia, id);

    return GestureDetector(
      onTap: () => _navegarABarberia(barberia, imageUrl),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.black.withOpacity(0.2), // Fondo de respaldo
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(_fotosAleatorias[id % _fotosAleatorias.length], fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 15, left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: const [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text("4.9", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20, left: 20, right: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(ubicacion, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Positioned(
              bottom: 15, right: 15,
              child: Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_outward_rounded, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalSquareCards() {
    int count = _barberias.length >= 3 ? 2 : 1;
    List<dynamic> sublist = _barberias.sublist(1, 1 + count);

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: sublist.length,
        itemBuilder: (context, index) {
          final barberia = sublist[index];
          final int id = barberia['id'] ?? barberia['idBarberia'] ?? 0;
          final String nombre = barberia['nombre'] ?? 'Sin nombre';
          final String ubicacion = barberia['zona'] ?? 'Local';
          final String imageUrl = _obtenerImagenBarberia(barberia, id + 1);

          return GestureDetector(
            onTap: () => _navegarABarberia(barberia, imageUrl),
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black.withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(_fotosAleatorias[(id + 1) % _fotosAleatorias.length], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15, left: 15, right: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(ubicacion, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10, right: 10,
                    child: Container(
                      width: 35, height: 35,
                      decoration: BoxDecoration(color: pinkAccent, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList() {
    List<dynamic> listCards = _barberias.sublist(3);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: listCards.length,
      itemBuilder: (context, index) {
        final barberia = listCards[index];
        final int id = barberia['id'] ?? barberia['idBarberia'] ?? 0;
        final String nombre = barberia['nombre'] ?? 'Sin nombre';
        final String ubicacion = barberia['zona'] ?? 'Local';
        final String imageUrl = _obtenerImagenBarberia(barberia, id + 2);

        return GestureDetector(
          onTap: () => _navegarABarberia(barberia, imageUrl),
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(_fotosAleatorias[(id + 2) % _fotosAleatorias.length], width: 70, height: 70, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(ubicacion, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(color: pinkAccent, borderRadius: BorderRadius.circular(12)),
                  child: const Text("Reservar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _navegarABarberia(dynamic barberia, String fotoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesClientScreen(
          barberiaId: barberia['id'] ?? barberia['idBarberia'] ?? 0,
          barberiaNombre: barberia['nombre'] ?? 'Barbería',
          barberiaDireccion: barberia['direccionCompleta'] ?? barberia['direccion'] ?? '',
          barberiaZona: barberia['zona'] ?? '',
          barberiaDescripcion: barberia['descripcion'] ?? 'Barbería Clásica',
          idCliente: widget.idUsuarioCliente,
          barberiaImagenUrl: fotoUrl,
        ),
      ),
    );
  }

  Widget _buildProfilePictureView() {
    return Container(
      width: 55, height: 55,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: ClipOval(
          child: _fotoUrlServidor != null
              ? Image.network(_fotoUrlServidor!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholderPic())
              : _buildPlaceholderPic()
      ),
    );
  }

  Widget _buildPlaceholderPic() {
    return Container(color: Colors.white.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.white, size: 30));
  }

  Widget _buildCategoriesChipsView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _activeCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _activeCategoryIndex = selected ? index : _activeCategoryIndex);
              },
              selectedColor: pinkAccent,
              backgroundColor: Colors.black.withOpacity(0.2),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              elevation: 0,
              showCheckmark: false,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }),
      ),
    );
  }

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
              _buildNavItem(Icons.receipt_long_rounded, 1, activeIndex, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentsScreen(idUsuarioCliente: widget.idUsuarioCliente)));
              }),
              _buildProfileNavItem(2, activeIndex),
              _buildNavItem(Icons.settings_rounded, 3, activeIndex, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(idCliente: widget.idUsuarioCliente)));
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
          color: isActive ? pinkAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 26),
      ),
    );
  }

  Widget _buildProfileNavItem(int index, int activeIndex) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileClientScreen())).then((_) => _cargarFotoPerfil());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: isActive ? pinkAccent : Colors.transparent, shape: BoxShape.circle),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isActive ? Colors.white : Colors.white70, width: 1.5)),
          child: ClipOval(
            child: _fotoUrlServidor != null
                ? Image.network(_fotoUrlServidor!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.white.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.white, size: 20)))
                : Container(color: Colors.white.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.white, size: 20)),
          ),
        ),
      ),
    );
  }
}