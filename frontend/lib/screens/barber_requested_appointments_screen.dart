import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() => _isLoading = true);
    try {
      final citasCargadas = await _apiService.getCitasPorBarbero(widget.idUsuarioBarbero, "PENDIENTE");
      setState(() { _citas = citasCargadas; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Error al cargar citas: $e", Colors.red);
    }
  }

  void _botonAceptar(int idCita) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.aceptarCita(idCita);
      if (exito) {
        _mostrarMensaje("¡Cita aceptada ✅!", Colors.green);
        _cargarCitas();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje(e.toString(), Colors.red);
    }
  }

  void _botonRechazar(int idCita) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.rechazarCita(idCita);
      if (exito) {
        _mostrarMensaje("Cita rechazada ❌", Colors.orange);
        _cargarCitas();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje(e.toString(), Colors.red);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // 🎨 CREADOR AUTOMÁTICO DE ETIQUETAS DE ESTADO
  Widget _buildEstadoBadge(String estadoRaw) {
    String estado = estadoRaw.toUpperCase();
    Color bgColor;
    Color textColor;

    switch (estado) {
      case 'PENDIENTE':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case 'ACEPTADA':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
      case 'COMPLETADA':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      case 'RECHAZADA':
      case 'CANCELADA':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        break;
      case 'VENCIDA':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.black54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
          estado,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)
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
              const Text("Citas Solicitadas", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                                child: const Icon(Icons.pending_actions_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text("Solicitudes pendientes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    SizedBox(height: 4),
                                    Text("Acepta o rechaza cada cita", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                ),
                              ),
                              // Badge contador
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFF6B35), width: 1),
                                ),
                                child: Text(
                                  "${_citas.length}",
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lista
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : _citas.isEmpty
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text("No hay solicitudes pendientes", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          )
                              : RefreshIndicator(
                            onRefresh: _cargarCitas,
                            color: mainColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _citas.length,
                              itemBuilder: (context, index) {
                                final cita = _citas[index];
                                final int idActual = cita['idCita'] ?? cita['id'];
                                final String cliente = cita['clienteReserva']?['nombre'] ?? "Cliente";
                                final String servicio = cita['servicioContratado']?['nombreServicio'] ?? "Servicio";
                                final String estado = cita['estadoCita'] ?? "PENDIENTE";

                                // 👇 Extracción inteligente del precio
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
                      _buildNavItem(Icons.calendar_month_rounded, active: true, onTap: () {}),
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

  Widget _buildCitaCard(int idCita, String cliente, String servicio, String fecha, String estado, String precio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
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
                    color: mainColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_rounded, color: mainColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 2),
                      Text(servicio, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                // 👇 Etiqueta dinámica insertada aquí
                _buildEstadoBadge(estado),
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
                    Text(fecha, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
                // 👇 El precio que verá el barbero para confirmar
                Text(precio, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _botonRechazar(idCita),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onPressed: () => _botonAceptar(idCita),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text("Aceptar", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
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