import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'calendar_client_screen.dart'; //

class ServicesClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final String barberiaDireccion;
  final String barberiaZona;
  final String barberiaDescripcion;
  final int idCliente; //  FECHA Y HORA ELIMINADOS

  const ServicesClientScreen({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
    this.barberiaDireccion = "Dirección no disponible",
    this.barberiaZona = "",
    this.barberiaDescripcion = "Barbería Clásica",
    required this.idCliente,
  });

  @override
  State<ServicesClientScreen> createState() => _ServicesClientScreenState();
}

class _ServicesClientScreenState extends State<ServicesClientScreen> {
  bool _isLoading = true;
  List<dynamic> _servicios = [];
  final ApiService _apiService = ApiService();

  final mainColor = const Color(0xFF381483);
  final accentBlue = const Color(0xFF2962FF);
  final accentPink = const Color(0xFFE96D71);
  final accentLilac = const Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    try {
      final data = await _apiService.getServiciosPorBarberia(widget.barberiaId);
      setState(() {
        _servicios = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error al cargar catálogo de esta barbería: $e');
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
                  "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60",
                  fit: BoxFit.cover,
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

            // ── TÍTULO CATÁLOGO ──
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(25, 30, 25, 15),
                child: Text("Elige tu servicio", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),

            // ── LISTA DE SERVICIOS ──
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              )
            else if (_servicios.isEmpty)
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
                      final double precioNum = servicio['precioServicio'] is num
                          ? (servicio['precioServicio'] as num).toDouble()
                          : 0.0;
                      final String precioStr = "${precioNum.toStringAsFixed(2)} €";
                      final String duracion = "${servicio['duracionMinutos'] ?? 30} min";

                      return _buildServiceCard(id, nombre, precioStr, duracion);
                    },
                    childCount: _servicios.length,
                  ),
                ),
              ),

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
                  // AHORA NAVEGAMOS AL CALENDARIO PASÁNDOLE LOS DATOS
                  onPressed: () {
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