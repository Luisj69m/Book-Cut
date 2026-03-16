import 'package:flutter/material.dart';
import 'settings_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF381483), // Fondo base
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [
              Color(0xFFE96D71),
              Color(0xFF381483),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER CON TÍTULO ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Mis Citas",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // --- TAB BAR SUPERIOR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF2962FF), // Azul vibrante
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  tabs: const [
                    Tab(text: "PRÓXIMAS"),
                    Tab(text: "HISTORIAL"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- CONTENIDO DE LAS PESTAÑAS (Las tarjetas están dentro) ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUpcomingAppointmentsTab(),
                        _buildAppointmentsHistoryTab(),
                      ],
                    ),
                  ),
                ),
              ),

              // --- BARRA INFERIOR (Actualizada) ---
              _buildBottomNavBar(context, activeIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PARA LA PESTAÑA DE CITAS PRÓXIMAS ---
  Widget _buildUpcomingAppointmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(25.0),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildUpcomingAppointmentCard(
          serviceName: "Degradado y barba",
          location: "La Rodola, Mérida",
          month: "NOV",
          day: "28",
          time: "17:00",
          isConfirmed: true,
        ),
        _buildUpcomingAppointmentCard(
          serviceName: "Corte clásico",
          location: "La Rodola, Mérida",
          month: "DIC",
          day: "14",
          time: "10:00",
          isConfirmed: false,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- WIDGET PARA LA PESTAÑA DE HISTORIAL ---
  Widget _buildAppointmentsHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(25.0),
      physics: const BouncingScrollPhysics(),
      children: [
        // Aquí está la tarjeta de una cita Cancelada, sin errores
        _buildHistoryAppointmentCard(
          serviceName: "Degradado",
          price: "12,00 €",
          duration: "30 min",
          month: "OCT",
          day: "14",
          time: "12:00",
          status: "Terminado",
        ),
        _buildHistoryAppointmentCard(
          serviceName: "Corte clásico",
          price: "11,00 €",
          duration: "15 min",
          month: "SEP",
          day: "19",
          time: "11:00",
          status: "Terminado",
        ),
        _buildHistoryAppointmentCard(
          serviceName: "Degradado y barba",
          price: "15,00 €",
          duration: "45 min",
          month: "AGO",
          day: "01",
          time: "17:00",
          status: "Cancelada",
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- WIDGET PARA TARJETAS DE CITAS PRÓXIMAS ---
  Widget _buildUpcomingAppointmentCard({
    required String serviceName,
    required String location,
    required String month,
    required String day,
    required String time,
    required bool isConfirmed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 3))
          ]
      ),
      child: Row(
        children: [
          // Lado izquierdo: Información del servicio
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.content_cut, size: 18, color: Color(0xFF2962FF)),
                    const SizedBox(width: 5),
                    Expanded( // Para evitar overflow si el nombre es muy largo
                      child: Text(
                        serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(location, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 12),

                // Botones de acción
                Row(
                  children: [
                    if (isConfirmed)
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
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {}, // TODO: _cancelAppointment
                      child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // Lado derecho: Fecha (Caja estilizada)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
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

  // --- WIDGET PARA TARJETAS DE HISTORIAL (Aquí está el arreglo del overflow) ---
  Widget _buildHistoryAppointmentCard({
    required String serviceName,
    required String price,
    required String duration,
    required String month,
    required String day,
    required String time,
    required String status,
  }) {
    bool isCancelled = status == "Cancelada";
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isCancelled ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2))
          ]
      ),
      child: Row(
        children: [
          // Lado izquierdo: Información
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AQUÍ ARREGLAMOS EL OVERFLOW: Usamos una fila pero blindada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // El nombre del servicio se expande pero con límites
                      child: Text(
                          serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCancelled ? Colors.grey.shade600 : Colors.black
                          )
                      ),
                    ),
                    const SizedBox(width: 8), // Pequeño espacio
                    Container( // El estado (Cancelada, etc.) tiene su sitio
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCancelled ? Colors.red.shade100 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          status,
                          style: TextStyle(
                              fontSize: 11,
                              color: isCancelled ? Colors.red.shade900 : Colors.grey.shade800,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text("La Rodola, Mérida", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 5),
                Text("$price • $duration", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
                const SizedBox(height: 12),

                // Botón de Reservar de Nuevo (solo para terminadas)
                if (!isCancelled)
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962FF), // Azul vibrante
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () {}, // TODO: _rebookAppointment
                      child: const Text("Reservar de nuevo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          // Lado derecho: Fecha
          Expanded(
            flex: 4,
            child: Opacity(
              opacity: isCancelled ? 0.6 : 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
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

  // --- WIDGET PARA LA BARRA INFERIOR ---
  Widget _buildBottomNavBar(BuildContext context, {required int activeIndex}) {
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
          IconButton(
            icon: Icon(Icons.receipt_long_outlined, color: activeIndex == 1 ? const Color(0xFF2962FF) : Colors.white, size: 30),
            onPressed: () {
              // Ya estamos en la pantalla
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today_outlined, color: activeIndex == 2 ? const Color(0xFF2962FF) : Colors.white, size: 28),
            onPressed: () {
              // TODO: Navegar a la pantalla del Calendario
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: activeIndex == 3 ? const Color(0xFF2962FF) : Colors.white, size: 32),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}