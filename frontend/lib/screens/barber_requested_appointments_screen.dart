import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart';
import 'settings_screen.dart';

class BarberRequestedAppointmentsScreen extends StatefulWidget {
  final int idUsuarioBarbero;

  const BarberRequestedAppointmentsScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<BarberRequestedAppointmentsScreen> createState() => _BarberRequestedAppointmentsScreenState();
}

class _BarberRequestedAppointmentsScreenState extends State<BarberRequestedAppointmentsScreen> {
  List<dynamic> _citas = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Colores corporativos (Mantenemos los de la Home del Barbero)
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);
  final accentLilac = const Color(0xFFB388FF);
  final warningOrange = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() => _isLoading = true);
    try {
      final citasCargadas = await _apiService.getCitasPorBarbero(widget.idUsuarioBarbero, "PENDIENTE");
      if (mounted) {
        setState(() { _citas = citasCargadas; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error de carga", "No se pudieron cargar las solicitudes: $e");
      }
    }
  }

  void _botonAceptar(int idCita) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.aceptarCita(idCita);
      if (exito && mounted) {
        GlassToast.showSuccess(context, "¡Cita Aceptada!", "La reserva ha sido confirmada correctamente.");
        _cargarCitas();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _botonRechazar(int idCita) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.rechazarCita(idCita);
      if (exito && mounted) {
        GlassToast.showWarning(context, "Cita Rechazada", "Se ha notificado al cliente de la cancelación.");
        _cargarCitas();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  //  ETIQUETAS DE ESTADO ADAPTADAS AL MODO OSCURO
  Widget _buildEstadoBadge(String estadoRaw) {
    String estado = estadoRaw.toUpperCase();
    Color bgColor;
    Color textColor;

    switch (estado) {
      case 'PENDIENTE':
        bgColor = warningOrange.withOpacity(0.2);
        textColor = warningOrange;
        break;
      case 'ACEPTADA':
        bgColor = Colors.greenAccent.withOpacity(0.2);
        textColor = Colors.greenAccent;
        break;
      case 'RECHAZADA':
      case 'CANCELADA':
        bgColor = Colors.redAccent.withOpacity(0.2);
        textColor = Colors.redAccent;
        break;
      default:
        bgColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.5), width: 1),
      ),
      child: Text(
          estado,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(activeIndex: 1),
        ),
      ),
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
          bottom: false,
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text("Solicitudes", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TARJETA DE CRISTAL (LISTA) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            // Cabecera del contenedor
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                        color: warningOrange.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: warningOrange, width: 1.5),
                                        boxShadow: [BoxShadow(color: warningOrange.withOpacity(0.4), blurRadius: 10)]
                                    ),
                                    child: const Icon(Icons.pending_actions_rounded, color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Citas por revisar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text("Acepta o rechaza cada solicitud", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // Badge contador
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: warningOrange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: warningOrange.withOpacity(0.5), width: 1),
                                    ),
                                    child: Text(
                                      "${_citas.length}",
                                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Lista scrolleable
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : _citas.isEmpty
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text("Todo al día.\nNo hay solicitudes pendientes.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                                ],
                              )
                                  : RefreshIndicator(
                                onRefresh: _cargarCitas,
                                color: warningOrange,
                                backgroundColor: mainColor,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // Espacio para la navbar
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _citas.length,
                                  itemBuilder: (context, index) {
                                    final cita = _citas[index];
                                    final int idActual = cita['idCita'] ?? cita['id'];
                                    final String cliente = cita['clienteReserva']?['nombre'] ?? "Cliente";
                                    final String servicio = cita['servicioContratado']?['nombreServicio'] ?? "Servicio";
                                    final String estado = cita['estadoCita'] ?? "PENDIENTE";

                                    final double precioCalculado = cita['precioFinal'] != null
                                        ? (cita['precioFinal'] as num).toDouble()
                                        : (cita['servicioContratado']?['precioServicio'] ?? cita['servicioContratado']?['precio'] ?? 0).toDouble();
                                    final String precioStr = precioCalculado > 0 ? "${precioCalculado.toStringAsFixed(2)} €" : "---";

                                    String fechaFormateada = "Sin fecha";
                                    try {
                                      final raw = cita['fechaHoraCita'] ?? "";
                                      if (raw.isNotEmpty) {
                                        final dt = DateTime.parse(raw);
                                        fechaFormateada = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                      }
                                    } catch (_) {}

                                    return _buildCitaCard(idActual, cliente, servicio, fechaFormateada, estado, precioStr);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitaCard(int idCita, String cliente, String servicio, String fecha, String estado, String precio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06), // Tarjeta oscura
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(servicio, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                ),
                _buildEstadoBadge(estado),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Text(fecha, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
                Text(precio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _botonRechazar(idCita),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _botonAceptar(idCita),
                    icon: const Icon(Icons.check_rounded, size: 18, color: Colors.black),
                    label: const Text("Aceptar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- EFECTO CRISTAL EN LA NAVBAR ---
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
              _buildNavItem(Icons.home_rounded, 0, activeIndex, () => Navigator.pop(context)),
              _buildNavItem(Icons.calendar_month_rounded, 1, activeIndex, () {}),
              _buildNavItem(Icons.settings_rounded, 2, activeIndex, () {
                Navigator.pushReplacement(context, MaterialPageRoute(
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
          color: isActive ? warningOrange : Colors.transparent, // Naranja para resaltar que es la pantalla de "Pendientes"
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 26),
      ),
    );
  }
}