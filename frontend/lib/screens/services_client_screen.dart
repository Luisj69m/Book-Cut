import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'calendar_client_screen.dart';
import '../utils/glass_toast.dart';

class ServicesClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final String barberiaDireccion;
  final String barberiaZona;
  final String barberiaDescripcion;
  final int idCliente;
  final String barberiaImagenUrl;

  const ServicesClientScreen({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
    this.barberiaDireccion = "Dirección no disponible",
    this.barberiaZona = "",
    this.barberiaDescripcion = "Barbería Clásica",
    required this.idCliente,
    required this.barberiaImagenUrl,
  });

  @override
  State<ServicesClientScreen> createState() => _ServicesClientScreenState();
}

class _ServicesClientScreenState extends State<ServicesClientScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _servicios = [];
  List<dynamic> _barberos = [];

  int? _selectedBarberoId;
  String? _selectedBarberoNombre;

  final mainColor = const Color(0xFF381483);
  final accentBlue = const Color(0xFF2962FF);
  final accentPink = const Color(0xFFE96D71);
  final accentLilac = const Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ️ EXTRACTOR  DE NOMBRES
  String _extraerNombreBarbero(dynamic b) {
    if (b == null) return 'Barbero';

    String n = '';
    String a = '';

    // 1. Busca en la estructura de 'usuarioAsignado'
    if (b['usuarioAsignado'] != null) {
      n = b['usuarioAsignado']['nombre'] ?? '';
      a = b['usuarioAsignado']['apellidos'] ?? '';
    }
    // 2. Si no, busca en la estructura plana 'nombreBarbero'
    else if (b['nombreBarbero'] != null) {
      n = b['nombreBarbero'] ?? '';
      a = b['apellidosBarbero'] ?? '';
    }
    // 3. Si no, busca en nombres genéricos
    else {
      n = b['nombre'] ?? '';
      a = b['apellidos'] ?? '';
    }

    if (n.isNotEmpty) return "$n $a".trim();
    return 'Barbero';
  }

  // 🛡️ EXTRACTOR DE FOTOS
  String? _extraerFotoBarbero(dynamic b) {
    if (b == null) return null;
    if (b['usuarioAsignado'] != null && b['usuarioAsignado']['urlFotoPerfil'] != null) {
      return b['usuarioAsignado']['urlFotoPerfil'];
    }
    return b['urlFotoPerfil'] ?? b['foto'];
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        _apiService.getServiciosPorBarberia(widget.barberiaId),
        _apiService.getBarberosPorBarberia(widget.barberiaId),
      ]);

      if (mounted) {
        setState(() {
          _servicios = resultados[0];
          _barberos = resultados[1];

          print("------------------------------------------------");
          print(" BARBEROS: $_barberos");
          print("------------------------------------------------");

          // Autoselección si solo hay 1
          if (_barberos.length == 1) {
            final b = _barberos[0];
            _selectedBarberoId = b['idPerfilBarbero'] ?? b['idBarbero'] ?? b['id'] ?? 0;
            _selectedBarberoNombre = _extraerNombreBarbero(b);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error al cargar datos de la barbería: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [accentPink, mainColor],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── CABECERA CON IMAGEN ──
            SliverAppBar(
              expandedHeight: 180.0,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2))
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  widget.barberiaImagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                        "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60",
                        fit: BoxFit.cover
                    );
                  },
                ),
              ),
            ),

            // ── INFO DE LA BARBERÍA (CRISTAL) ──
            SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.barberiaNombre, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_rounded, color: accentPink, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text("${widget.barberiaDireccion}, ${widget.barberiaZona}", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.3)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.withOpacity(0.5))),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 18),
                                  const SizedBox(width: 4),
                                  const Text("5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orangeAccent)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: accentLilac.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: accentLilac.withOpacity(0.5))),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded, color: accentLilac, size: 16),
                                  const SizedBox(width: 6),
                                  Text("Cita para hoy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentLilac)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text("Sobre el local", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentLilac)),
                        const SizedBox(height: 8),
                        Text(widget.barberiaDescripcion, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              )
            else ...[

              // ── 1. SECCIÓN: ELIGE TU PROFESIONAL (BARBEROS) ──
              if (_barberos.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 30, 25, 15),
                    child: Text("1. Elige tu Profesional", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _barberos.length,
                      itemBuilder: (context, index) {
                        final barbero = _barberos[index];
                        final int id = barbero['idPerfilBarbero'] ?? barbero['idBarbero'] ?? barbero['id'] ?? 0;


                        final String nombreMostrar = _extraerNombreBarbero(barbero);
                        final String? foto = _extraerFotoBarbero(barbero);
                        final String especialidad = barbero['especialidadCorte'] ?? barbero['especialidad'] ?? 'Especialista';

                        final bool isSelected = _selectedBarberoId == id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBarberoId = id;
                              _selectedBarberoNombre = nombreMostrar;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 130,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? accentLilac.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  color: isSelected ? accentLilac : Colors.white.withOpacity(0.15),
                                  width: isSelected ? 2 : 1.5
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: accentLilac.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)] : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isSelected ? Colors.white : Colors.white54, width: 2)
                                  ),
                                  child: ClipOval(
                                    child: foto != null && foto.isNotEmpty
                                        ? Image.network(foto, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.person, color: Colors.white))
                                        : const Icon(Icons.person, color: Colors.white, size: 30),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(nombreMostrar, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(especialidad, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // ── 2. SECCIÓN: ELIGE TU SERVICIO ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 30, 25, 15),
                  child: Text("2. Elige tu Servicio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),

              if (_servicios.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.content_cut_outlined, size: 50, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 10),
                          Text("No hay servicios disponibles", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final servicio = _servicios[index];
                        final int id = servicio['idServicio'];
                        final String nombre = servicio['nombreServicio'] ?? 'Corte';
                        final double precioNum = servicio['precioServicio'] is num ? (servicio['precioServicio'] as num).toDouble() : 0.0;
                        final String precioStr = "${precioNum.toStringAsFixed(2)} €";
                        final String duracion = "${servicio['duracionMinutos'] ?? 30} min";

                        return _buildServiceCard(id, nombre, precioStr, duracion);
                      },
                      childCount: _servicios.length,
                    ),
                  ),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  // ── TARJETA DE SERVICIO DE CRISTAL ──
  Widget _buildServiceCard(int id, String nombre, String precio, String duracion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: accentLilac.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: accentLilac.withOpacity(0.3))
              ),
              child: Icon(Icons.content_cut_rounded, color: accentLilac),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(duracion, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(precio, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.greenAccent)),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentLilac,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: () {
                    if (_selectedBarberoId == null) {
                      GlassToast.showWarning(context, "Falta el profesional", "Por favor, selecciona un barbero de la lista superior primero.");
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarClientScreen(
                          barberiaId: widget.barberiaId,
                          barberiaNombre: widget.barberiaNombre,
                          barberiaDireccion: widget.barberiaDireccion,
                          barberiaZona: widget.barberiaZona,
                          barberiaDescripcion: widget.barberiaDescripcion,
                          idCliente: widget.idCliente,
                          idServicio: id,
                          nombreServicio: nombre,
                          precioServicio: precio,
                          idBarbero: _selectedBarberoId!,
                          nombreBarbero: _selectedBarberoNombre!,
                        ),
                      ),
                    );
                  },
                  child: const Text("Seleccionar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}