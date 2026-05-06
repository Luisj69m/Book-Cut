import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:frontend/utils/api_config.dart';
import 'profile_client_screen.dart';
import 'settings_screen.dart';

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

  // Variable para la foto de perfil en la barra de navegación
  String? _fotoUrlServidor;

  // --- COLORES CORPORATIVOS ---
  final Color bgDarkPurple = const Color(0xFF381483);
  final Color accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarMisCitas();
    _cargarFotoPerfil(); // Cargamos la foto al entrar
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA TRAER LA FOTO DE IVÁN ---
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

  // --- LÓGICA DE CITAS ---
  Future<void> _cargarMisCitas() async {
    setState(() => _isLoading = true);
    try {
      final todasLasCitas = await _apiService.getMisCitas(widget.idUsuarioCliente);

      List<dynamic> proximas = [];
      List<dynamic> historial = [];

      for (var cita in todasLasCitas) {
        String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();

        // Si está pendiente o aceptada, a próximas. El resto (Completadas, Canceladas, Rechazadas y VENCIDAS) al historial.
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar citas: $e"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating)
      );
    }
  }

  Future<void> _ejecutarCancelacion(int idCita) async {
    setState(() => _isLoading = true);
    try {
      bool exito = await _apiService.cancelarCitaDefinitiva(idCita);
      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cita cancelada correctamente. Revisa tu correo."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
          );
        }
        await _cargarMisCitas();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No se pudo cancelar la cita."), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoCancelacion(int idCita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE96D71), size: 50),
              const SizedBox(height: 15),
              const Text(
                "¿Cancelar cita?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text(
                "¿Estás seguro de que deseas cancelar esta reserva? Se notificará al barbero y recibirás un correo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentBlue,
                        side: BorderSide(color: accentBlue.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Mantener", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE96D71),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  // 🎨 CREADOR AUTOMÁTICO DE ETIQUETAS DE ESTADO (Integrado para VENCIDA y demás)
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
      case 'VENCIDA': // 💀 EL NUEVO ESTADO DE IVÁN
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
      backgroundColor: bgDarkPurple,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          child: _buildFloatingNavBar(context, activeIndex: 1),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [Color(0xFFE96D71), Color(0xFF381483)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    const Text("Mis Citas", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: accentBlue,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  tabs: const [Tab(text: "PRÓXIMAS"), Tab(text: "HISTORIAL")],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                        : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildListaCitas(_citasProximas, esHistorial: false),
                        _buildListaCitas(_citasHistorial, esHistorial: true),
                      ],
                    ),
                  ),
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
      return const Center(
          child: Text("No hay citas en esta sección.",
              style: TextStyle(color: Colors.grey, fontSize: 16)));
    }
    return RefreshIndicator(
      onRefresh: _cargarMisCitas,
      color: const Color(0xFF381483),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0, bottom: 110.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];
          final int idCita = cita['idCita'] ?? cita['id'] ?? 0;

          final servicio = cita['servicioContratado']?['nombreServicio'] ??
              cita['servicioContratado']?['nombre'] ??
              "Corte";

          // 👇 LÓGICA INTELIGENTE DEL PRECIO (Prioriza el precioFinal de Iván)
          final double precioCalculado = cita['precioFinal'] != null
              ? (cita['precioFinal'] as num).toDouble()
              : (cita['servicioContratado']?['precioServicio'] ?? cita['servicioContratado']?['precio'] ?? 0).toDouble();

          final String precioStr = precioCalculado > 0 ? "${precioCalculado.toStringAsFixed(2)}" : "---";

          final duracion = cita['servicioContratado']?['duracionMinutos']?.toString() ??
              cita['servicioContratado']?['duracion']?.toString() ??
              "---";

          final estado = (cita['estadoCita'] ?? "DESCONOCIDO").toString().toUpperCase();
          final fechaMap = _formatearFecha(cita['fechaHoraCita'] ?? "");

          if (esHistorial) {
            return _buildHistoryAppointmentCard(
              serviceName: servicio,
              price: "$precioStr €",
              duration: "$duracion min",
              month: fechaMap['mes']!,
              day: fechaMap['dia']!,
              time: fechaMap['hora']!,
              status: estado,
            );
          } else {
            return _buildUpcomingAppointmentCard(
              serviceName: servicio,
              location: "La Rodola, Mérida",
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

  // --- TARJETA PRÓXIMAS ---
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))]
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
                    Icon(Icons.content_cut, size: 18, color: accentBlue),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(serviceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(location, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 👇 Aquí hemos insertado la etiqueta automática
                    _buildEstadoBadge(status),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: onCancel,
                      child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Text(day, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333), height: 1)),
                  Text(month, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentBlue)),
                  const SizedBox(height: 5),
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 5),
                  Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TARJETA HISTORIAL ---
  Widget _buildHistoryAppointmentCard({
    required String serviceName,
    required String price,
    required String duration,
    required String month,
    required String day,
    required String time,
    required String status,
  }) {
    bool isCancelledOrExpired = status == "CANCELADA" || status == "RECHAZADA" || status == "VENCIDA";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isCancelledOrExpired ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))]
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(serviceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCancelledOrExpired ? Colors.grey.shade600 : Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    // 👇 Aquí hemos insertado la etiqueta automática
                    _buildEstadoBadge(status),
                  ],
                ),
                const SizedBox(height: 5),
                Text("La Rodola, Mérida", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 5),
                Text("$price • $duration", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Opacity(
              opacity: isCancelledOrExpired ? 0.6 : 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    Text(day, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF666666), height: 1)),
                    Text(month, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCancelledOrExpired ? Colors.grey : accentBlue)),
                    const SizedBox(height: 5),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 5),
                    Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, {required int activeIndex}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF381483),
          borderRadius: BorderRadius.circular(40),
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
          _buildNavItem(Icons.home_rounded, 0, activeIndex, () {
            Navigator.pop(context);
          }),
          _buildNavItem(Icons.receipt_long_rounded, 1, activeIndex, () {}),
          _buildProfileNavItem(2, activeIndex),
          _buildNavItem(Icons.settings_rounded, 3, activeIndex, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen(idCliente: widget.idUsuarioCliente)),
            );
          }),
        ],
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

  Widget _buildProfileNavItem(int index, int activeIndex) {
    final isActive = index == activeIndex;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileClientScreen()),
        ).then((_) {
          _cargarFotoPerfil();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(4),
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