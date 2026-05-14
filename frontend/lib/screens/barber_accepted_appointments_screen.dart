import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart'; // ✅ IMPORTAMOS NUESTRO TOAST PREMIUM
import 'settings_screen.dart';

class BarberAcceptedAppointmentsScreen extends StatefulWidget {
  final int idUsuarioBarbero;
  const BarberAcceptedAppointmentsScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<BarberAcceptedAppointmentsScreen> createState() => _BarberAcceptedAppointmentsScreenState();
}

class _BarberAcceptedAppointmentsScreenState extends State<BarberAcceptedAppointmentsScreen> {
  int? _expandedAppointmentId;
  List<dynamic> _citasAceptadas = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Colores corporativos (Mantenemos la paleta Dark Mode del Barbero)
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);
  final accentLilac = const Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();
    _cargarCitasAceptadas();
  }

  Future<void> _cargarCitasAceptadas() async {
    setState(() => _isLoading = true);
    try {
      final citas = await _apiService.getCitasPorBarbero(widget.idUsuarioBarbero, "ACEPTADA");
      if (mounted) {
        setState(() {
          _citasAceptadas = citas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error", "No se pudieron cargar las citas aceptadas");
      }
    }
  }

  void _finalizarCita(int id) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.completarCita(id);

      if (exito && mounted) {
        setState(() => _citasAceptadas.removeWhere((c) => (c['idCita'] ?? c['id']) == id));
        GlassToast.showSuccess(context, "¡Completada!", "Cita cobrada con éxito 💰");
      } else {
        if (mounted) GlassToast.showError(context, "Error", "No se pudo completar la cita");
        _cargarCitasAceptadas();
      }
    } catch (e) {
      _cargarCitasAceptadas();
      if (mounted) GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _cancelarCita(int id) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.cancelarCitaDefinitiva(id);

      if (exito && mounted) {
        setState(() => _citasAceptadas.removeWhere((c) => (c['idCita'] ?? c['id']) == id));
        GlassToast.showWarning(context, "Cita Cancelada", "Se ha notificado al cliente.");
      } else {
        if (mounted) GlassToast.showError(context, "Error", "No se pudo cancelar la cita");
        _cargarCitasAceptadas();
      }
    } catch (e) {
      _cargarCitasAceptadas();
      if (mounted) GlassToast.showError(context, "Error", e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(),
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
                    const Text("Agenda", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TARJETA DE CRISTAL PRINCIPAL ──
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
                                        color: Colors.greenAccent.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.greenAccent, width: 1.5),
                                        boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 10)]
                                    ),
                                    child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Citas Aceptadas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text("Finaliza o cancela cada cita", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // Badge contador
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
                                    ),
                                    child: Text(
                                        "${_citasAceptadas.length}",
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Lista scrolleable
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : _citasAceptadas.isEmpty
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_available_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text("Agenda despejada.\nNo tienes citas próximas.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                                ],
                              )
                                  : RefreshIndicator(
                                onRefresh: _cargarCitasAceptadas,
                                color: Colors.greenAccent,
                                backgroundColor: mainColor,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // Espacio inferior para navbar
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _citasAceptadas.length,
                                  itemBuilder: (context, index) {
                                    final cita = _citasAceptadas[index];
                                    final int idCita = cita["idCita"] ?? cita["id"];
                                    final String fechaHora = cita["fechaHoraCita"] ?? "";

                                    String hora = "00:00";
                                    String fecha = "Sin fecha";

                                    if (fechaHora.isNotEmpty && fechaHora.contains('T')) {
                                      hora = fechaHora.split('T')[1].substring(0, 5);
                                      final partes = fechaHora.split('T')[0].split('-');
                                      fecha = partes.length == 3 ? "${partes[2]}/${partes[1]}/${partes[0]}" : fechaHora.split('T')[0];
                                    }

                                    final String cliente = cita["clienteReserva"]?["nombre"] ?? cita["clienteReserva"]?["correoElectronico"] ?? "Cliente";
                                    final String servicio = cita["servicioContratado"]?["nombreServicio"] ?? "Servicio";

                                    final double precioCalculado = cita['precioFinal'] != null
                                        ? (cita['precioFinal'] as num).toDouble()
                                        : (cita['servicioContratado']?['precioServicio'] ?? cita['servicioContratado']?['precio'] ?? 0).toDouble();
                                    final String precioStr = precioCalculado > 0 ? "${precioCalculado.toStringAsFixed(2)} €" : "---";

                                    final bool isExpanded = _expandedAppointmentId == idCita;

                                    return _buildCitaCard(idCita, cliente, servicio, fecha, hora, precioStr, isExpanded);
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

  Widget _buildCitaCard(int idCita, String cliente, String servicio, String fecha, String hora, String precio, bool isExpanded) {
    return GestureDetector(
      onTap: () => setState(() => _expandedAppointmentId = isExpanded ? null : idCita),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isExpanded ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isExpanded ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1), width: 1.5),
          boxShadow: [
            if (isExpanded) BoxShadow(color: Colors.greenAccent.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(servicio, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    child: const Text("Aceptada", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 0.5)),
                  ),
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
                      Text("$fecha • $hora", style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(precio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),

              // ── SECCIÓN EXPANDIDA (BOTONES) ──
              if (isExpanded) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelarCita(idCita),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        onPressed: () => _finalizarCita(idCita),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.black),
                        label: const Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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

              // ── INDICADOR DE EXPANSIÓN ──
              if (!isExpanded)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.3)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // --- EFECTO CRISTAL EN LA NAVBAR ---
  Widget _buildGlassmorphicNavBar() {
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
              _buildNavItem(Icons.home_rounded, false, () => Navigator.pop(context)),
              _buildNavItem(Icons.check_circle_rounded, true, () {}), // Marcado activo
              _buildNavItem(Icons.settings_rounded, false, () {
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

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.greenAccent.withOpacity(0.2) : Colors.transparent, // Resalte verde sutil
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.greenAccent : Colors.white70, size: 26),
      ),
    );
  }
}