import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  final ApiService _apiService = ApiService(); // Instancia centralizada

  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _cargarCitasAceptadas();
  }

  Future<void> _cargarCitasAceptadas() async {
    setState(() => _isLoading = true);
    try {
      final citas = await _apiService.getCitasPorBarbero(widget.idUsuarioBarbero, "ACEPTADA");
      setState(() {
        _citasAceptadas = citas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Error al cargar citas", Colors.red);
    }
  }

  // 🛠️ ARREGLADO: Ahora usamos completarCita y comprobamos que devuelva true
  void _finalizarCita(int id) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.completarCita(id);

      if (exito) {
        // Borramos al instante para que la UI sea rápida
        setState(() => _citasAceptadas.removeWhere((c) => (c['idCita'] ?? c['id']) == id));
        _mostrarMensaje('Cita cobrada con éxito 💰', Colors.green);
      } else {
        _mostrarMensaje('No se pudo completar la cita', Colors.redAccent);
        _cargarCitasAceptadas(); // Recargamos por si acaso
      }
    } catch (e) {
      _cargarCitasAceptadas();
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.redAccent);
    }
  }

  // 🛠️ ARREGLADO: Comprobación estricta de éxito para cancelar
  void _cancelarCita(int id) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.cancelarCitaDefinitiva(id);

      if (exito) {
        setState(() => _citasAceptadas.removeWhere((c) => (c['idCita'] ?? c['id']) == id));
        _mostrarMensaje('Cita cancelada', Colors.orange);
      } else {
        _mostrarMensaje('No se pudo cancelar la cita', Colors.redAccent);
        _cargarCitasAceptadas();
      }
    } catch (e) {
      _cargarCitasAceptadas();
      _mostrarMensaje(e.toString().replaceAll('Exception: ', ''), Colors.redAccent);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating
        ),
      );
    }
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
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.white, child: Icon(Icons.content_cut, color: mainColor, size: 36)),
                      ),
                    ),
                  ),
                ),
              ),
              const Text("Citas Aceptadas", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 20),

              // ── TARJETA PRINCIPAL ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // Cabecera degradada
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF381483), Color(0xFF2962FF)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
                                ),
                                child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Próximas confirmadas", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    SizedBox(height: 4),
                                    Text("Finaliza o cancela cada cita", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300, width: 1),
                                ),
                                child: Text("${_citasAceptadas.length}", style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        // Lista
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : _citasAceptadas.isEmpty
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text("No tienes citas próximas", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          )
                              : RefreshIndicator(
                            onRefresh: _cargarCitasAceptadas,
                            color: mainColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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

                                // 👇 EXTRACCIÓN INTELIGENTE DEL PRECIO
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

              const SizedBox(height: 12),

              // ── NAV BAR ──
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, onTap: () => Navigator.pop(context)),
                      _buildNavItem(Icons.check_circle_rounded, active: true, onTap: () {}),
                      _buildNavItem(Icons.settings_rounded, onTap: () {}),
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

  Widget _buildCitaCard(int idCita, String cliente, String servicio, String fecha, String hora, String precio, bool isExpanded) {
    return GestureDetector(
      onTap: () => setState(() => _expandedAppointmentId = isExpanded ? null : idCita),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExpanded ? accentBlue.withOpacity(0.4) : Colors.grey.shade100, width: 1.5),
          boxShadow: [BoxShadow(color: isExpanded ? accentBlue.withOpacity(0.10) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
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
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.content_cut, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(servicio, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text("Aceptada", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text("$fecha • $hora", style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // 👇 Aquí mostramos el precio final al barbero
                  Text(precio, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelarCita(idCita),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizarCita(idCita),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // Indicador de expansión si no está expandido
              if (!isExpanded)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }
}