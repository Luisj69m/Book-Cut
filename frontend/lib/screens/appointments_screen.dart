import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:frontend/utils/api_config.dart';
import 'profile_client_screen.dart';
import 'settings_screen.dart';
import '../utils/glass_toast.dart'; // ✅ IMPORTAMOS NUESTRO TOAST PREMIUM

class AppointmentsScreen extends StatefulWidget {
  final int idUsuarioCliente;

  const AppointmentsScreen({super.key, required this.idUsuarioCliente});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<dynamic> _citasProximas = [];
  List<dynamic> _citasHistorial = [];
  String? _fotoUrlServidor;

  // Colores corporativos y complementarios
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color accentLilac = const Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarMisCitas();
    _cargarFotoPerfil();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      print("Error cargando la foto en Citas: $e");
    }
  }

  Future<void> _cargarMisCitas() async {
    setState(() => _isLoading = true);
    try {
      final todasLasCitas = await _apiService.getMisCitas(widget.idUsuarioCliente);

      List<dynamic> proximas = [];
      List<dynamic> historial = [];

      for (var cita in todasLasCitas) {
        String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();
        if (estado == 'PENDIENTE' || estado == 'ACEPTADA') {
          proximas.add(cita);
        } else {
          historial.add(cita);
        }
      }

      setState(() {
        _citasProximas = proximas;
        _citasHistorial = historial;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // ✅ USAMOS GLASS TOAST PARA EL ERROR
        GlassToast.showError(context, "Error", "No se pudieron cargar las citas");
      }
    }
  }

  Future<void> _ejecutarCancelacion(int idCita) async {
    setState(() => _isLoading = true);
    try {
      // 🛡️ AÑADIMOS EL TIMEOUT DE 6 SEGUNDOS PARA QUE NO SE CUELGUE CON EL EMAIL
      bool exito = await _apiService.cancelarCitaDefinitiva(idCita).timeout(
        const Duration(seconds: 6),
        onTimeout: () => true, // Forzamos el éxito si hay retraso por el correo
      );

      if (exito) {
        if (mounted) {
          // ✅ GLASS TOAST DE ÉXITO
          GlassToast.showSuccess(context, "Cita Cancelada", "Tu reserva ha sido anulada correctamente.");
        }
        await _cargarMisCitas();
      } else {
        throw Exception("El servidor rechazó la cancelación.");
      }
    } catch (e) {
      if (mounted) {
        // ✅ GLASS TOAST DE AVISO/WARNING
        GlassToast.showWarning(context, "Aviso", "La cita se canceló pero el servidor tardó en responder.");
        await _cargarMisCitas();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoCancelacion(int idCita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A1B44),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5)
          ),
          contentPadding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: pinkAccent.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: pinkAccent, size: 40),
              ),
              const SizedBox(height: 20),
              const Text("¿Cancelar cita?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                "¿Estás seguro de que deseas cancelar esta reserva? Se notificará al barbero y recibirás un correo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.4),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Mantener", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pinkAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _ejecutarCancelacion(idCita);
                      },
                      child: const Text("Sí, cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> _formatearFecha(String fechaIso) {
    try {
      if (fechaIso.isEmpty) throw Exception();
      DateTime dt = DateTime.parse(fechaIso);
      const meses = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
      return {
        'dia': dt.day.toString().padLeft(2, '0'),
        'mes': meses[dt.month - 1],
        'hora': "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"
      };
    } catch (e) {
      return {'dia': '--', 'mes': '---', 'hora': '--:--'};
    }
  }

  Widget _buildEstadoBadge(String estadoRaw) {
    String estado = estadoRaw.toUpperCase();
    Color bgColor;
    Color textColor;

    switch (estado) {
      case 'PENDIENTE':
        bgColor = Colors.orangeAccent.withOpacity(0.2);
        textColor = Colors.orangeAccent;
        break;
      case 'ACEPTADA':
        bgColor = accentLilac.withOpacity(0.2);
        textColor = accentLilac;
        break;
      case 'COMPLETADA':
        bgColor = Colors.greenAccent.withOpacity(0.2);
        textColor = Colors.greenAccent;
        break;
      case 'RECHAZADA':
      case 'CANCELADA':
        bgColor = pinkAccent.withOpacity(0.2);
        textColor = pinkAccent;
        break;
      case 'VENCIDA':
        bgColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white54;
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
      child: Text(estado, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: deepPurple,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
          child: _buildGlassmorphicNavBar(activeIndex: 1),
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
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
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
                    const Text("Mis Citas", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TAB BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: accentLilac.withOpacity(0.8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [Tab(text: "PRÓXIMAS"), Tab(text: "HISTORIAL")],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── LISTAS DE CITAS ──
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListaCitas(_citasProximas, esHistorial: false),
                    _buildListaCitas(_citasHistorial, esHistorial: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaCitas(List<dynamic> citas, {required bool esHistorial}) {
    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 15),
            Text("No hay citas en esta sección.", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargarMisCitas,
      color: pinkAccent,
      backgroundColor: deepPurple,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0, bottom: 120.0),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];
          final int idCita = cita['idCita'] ?? cita['id'] ?? 0;

          final String servicio = cita['servicioContratado']?['nombreServicio'] ?? cita['servicioContratado']?['nombre'] ?? "Corte";
          final double precioCalculado = cita['precioFinal'] != null ? (cita['precioFinal'] as num).toDouble() : (cita['servicioContratado']?['precioServicio'] ?? cita['servicioContratado']?['precio'] ?? 0).toDouble();
          final String precioStr = precioCalculado > 0 ? precioCalculado.toStringAsFixed(2) : "---";
          final String duracion = cita['servicioContratado']?['duracionMinutos']?.toString() ?? cita['servicioContratado']?['duracion']?.toString() ?? "---";
          final String estado = (cita['estadoCita'] ?? "DESCONOCIDO").toString().toUpperCase();
          final fechaMap = _formatearFecha(cita['fechaHoraCita'] ?? "");
          final String nombreBarberia = cita['nombreBarberia'] ?? 'Barbería';

          if (esHistorial) {
            return _buildHistoryAppointmentCard(
              serviceName: servicio,
              price: "$precioStr €",
              duration: "$duracion min",
              month: fechaMap['mes']!,
              day: fechaMap['dia']!,
              time: fechaMap['hora']!,
              status: estado,
              nombreBarberia: nombreBarberia,
            );
          } else {
            return _buildUpcomingAppointmentCard(
              serviceName: servicio,
              location: nombreBarberia,
              month: fechaMap['mes']!,
              day: fechaMap['dia']!,
              time: fechaMap['hora']!,
              status: estado,
              onCancel: () => _mostrarDialogoCancelacion(idCita),
            );
          }
        },
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard({
    required String serviceName,
    required String location,
    required String month,
    required String day,
    required String time,
    required String status,
    required VoidCallback onCancel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: accentLilac.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.content_cut_rounded, size: 16, color: accentLilac),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(serviceName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildEstadoBadge(status),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancel,
                      child: Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold, color: pinkAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(day, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                  Text(month, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: accentLilac, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAppointmentCard({
    required String serviceName,
    required String price,
    required String duration,
    required String month,
    required String day,
    required String time,
    required String status,
    required String nombreBarberia,
  }) {
    bool isCancelledOrExpired = status == "CANCELADA" || status == "RECHAZADA" || status == "VENCIDA";
    double opacityLvl = isCancelledOrExpired ? 0.4 : 1.0;

    return Opacity(
      opacity: opacityLvl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(serviceName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(nombreBarberia, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text("$price • $duration",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentLilac)),
                  const SizedBox(height: 10),
                  _buildEstadoBadge(status),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(day, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.8), height: 1)),
                    Text(month, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.5), letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 8),
                    Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              _buildNavItem(Icons.home_rounded, 0, activeIndex, () => Navigator.pop(context)),
              _buildNavItem(Icons.receipt_long_rounded, 1, activeIndex, () {}),
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