import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final int idUsuarioCliente; // <-- NECESARIO PARA PEDIR LAS CITAS

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarMisCitas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LÓGICA PARA CARGAR Y FILTRAR CITAS ---
  Future<void> _cargarMisCitas() async {
    setState(() => _isLoading = true);
    try {
      final todasLasCitas = await _apiService.getMisCitas(widget.idUsuarioCliente);

      List<dynamic> proximas = [];
      List<dynamic> historial = [];

      for (var cita in todasLasCitas) {
        String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();

        // Clasificamos según el estado
        if (estado == 'PENDIENTE' || estado == 'ACEPTADA') {
          proximas.add(cita);
        } else {
          // Completadas, Canceladas, Rechazadas...
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
          SnackBar(content: Text("Error al cargar citas: $e"), backgroundColor: Colors.red)
      );
    }
  }

  // --- PARSEADOR DE FECHAS ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF381483),
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
              // Header
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

              // TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF2962FF),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  tabs: const [Tab(text: "PRÓXIMAS"), Tab(text: "HISTORIAL")],
                ),
              ),

              const SizedBox(height: 10),

              // Contenido
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
                        ? const Center(child: CircularProgressIndicator())
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

              _buildBottomNavBar(context, activeIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET GENÉRICO PARA LISTAR CITAS ---
  Widget _buildListaCitas(List<dynamic> citas, {required bool esHistorial}) {
    if (citas.isEmpty) {
      return const Center(child: Text("No hay citas en esta sección.", style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    return RefreshIndicator(
      onRefresh: _cargarMisCitas,
      child: ListView.builder(
        padding: const EdgeInsets.all(25.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];

          // Extracción segura de datos
          final servicio = cita['servicioContratado']?['nombreServicio'] ?? cita['servicioContratado']?['nombre'] ?? "Corte";
          final estado = (cita['estadoCita'] ?? "DESCONOCIDO").toString().toUpperCase();
          final fechaMap = _formatearFecha(cita['fechaHoraCita'] ?? "");

          if (esHistorial) {
            return _buildHistoryAppointmentCard(
              serviceName: servicio,
              price: "--- €", // O extraer de la BD
              duration: "--- min",
              month: fechaMap['mes']!,
              day: fechaMap['dia']!,
              time: fechaMap['hora']!,
              status: estado, // Muestra "COMPLETADA", "RECHAZADA", etc.
            );
          } else {
            return _buildUpcomingAppointmentCard(
              serviceName: servicio,
              location: "La Rodola, Mérida",
              month: fechaMap['mes']!,
              day: fechaMap['dia']!,
              time: fechaMap['hora']!,
              status: estado, // Pasamos el estado para que cambie de color
            );
          }
        },
      ),
    );
  }

  // --- TARJETA PRÓXIMAS (DINÁMICA POR ESTADO) ---
  Widget _buildUpcomingAppointmentCard({
    required String serviceName,
    required String location,
    required String month,
    required String day,
    required String time,
    required String status,
  }) {
    // Lógica visual basada en el estado
    bool isAccepted = status == 'ACEPTADA';

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
                    const Icon(Icons.content_cut, size: 18, color: Color(0xFF2962FF)),
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
                    // --- CHIP DE ESTADO DINÁMICO ---
                    if (isAccepted)
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text("Confirmada", style: TextStyle(fontSize: 13, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Text("Pendiente", style: TextStyle(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                      ),

                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red.shade700, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () {},
                      child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Caja de fecha
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  Text(day, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF333333), height: 1)),
                  Text(month, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2962FF))),
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
    bool isCancelled = status == "CANCELADA" || status == "RECHAZADA";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isCancelled ? Colors.grey.shade200 : Colors.grey.shade100,
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
                      child: Text(serviceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isCancelled ? Colors.grey.shade600 : Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: isCancelled ? Colors.red.shade100 : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                      child: Text(status, style: TextStyle(fontSize: 10, color: isCancelled ? Colors.red.shade900 : Colors.grey.shade800, fontWeight: FontWeight.bold)),
                    ),
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
              opacity: isCancelled ? 0.6 : 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    Text(day, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF666666), height: 1)),
                    Text(month, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCancelled ? Colors.grey : const Color(0xFF2962FF))),
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

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNavBar(BuildContext context, {required int activeIndex}) {
    //
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: activeIndex == 0 ? const Color(0xFF2962FF) : Colors.white, size: 32),
            onPressed: () {
              if (activeIndex != 0) Navigator.pop(context);
            },
          ),
          IconButton(icon: Icon(Icons.receipt_long_outlined, color: activeIndex == 1 ? const Color(0xFF2962FF) : Colors.white, size: 30), onPressed: () {}),
          IconButton(icon: Icon(Icons.calendar_today_outlined, color: activeIndex == 2 ? const Color(0xFF2962FF) : Colors.white, size: 28), onPressed: () {}),
          IconButton(icon: Icon(Icons.help_outline, color: activeIndex == 3 ? const Color(0xFF2962FF) : Colors.white, size: 32), onPressed: () {}),
        ],
      ),
    );
  }
}