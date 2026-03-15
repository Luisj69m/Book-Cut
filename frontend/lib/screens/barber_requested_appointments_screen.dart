import 'package:flutter/material.dart';

class BarberRequestedAppointmentsScreen extends StatefulWidget {
  const BarberRequestedAppointmentsScreen({super.key});

  @override
  State<BarberRequestedAppointmentsScreen> createState() => _BarberRequestedAppointmentsScreenState();
}

class _BarberRequestedAppointmentsScreenState extends State<BarberRequestedAppointmentsScreen> {
  // Colores de la app
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final cardBgColor = const Color(0xFFE5DDFD);

  // Variable para controlar qué tarjeta está expandida (abierta)
  int? _expandedAppointmentId;

  // DATOS MOCK: Simulamos las citas que llegarán de la base de datos de Iván
  // Más adelante, esto se llenará con un ApiService().getCitasPendientes()
  final List<Map<String, dynamic>> _citasPendientes = [
    {
      "id": 1,
      "fecha": "Lunes 15 de Noviembre",
      "hora": "18:00",
      "cliente": "Manuel Sanchez",
      "servicio": "Corte Clásico"
    },
    {
      "id": 2,
      "fecha": "Martes 16 de Noviembre",
      "hora": "13:00",
      "cliente": "Jose María Gutiérrez Guti",
      "servicio": "Degradado y barba"
    },
    {
      "id": 3,
      "fecha": "Miércoles 17 de Noviembre",
      "hora": "12:00",
      "cliente": "Risi Alvaro",
      "servicio": "Arreglo de barba"
    },
    {
      "id": 4,
      "fecha": "Jueves 18 de Noviembre",
      "hora": "10:30",
      "cliente": "Carlos Ruiz",
      "servicio": "Corte a tijera"
    },
    {
      "id": 5,
      "fecha": "Viernes 19 de Noviembre",
      "hora": "17:45",
      "cliente": "David Meca",
      "servicio": "Degradado"
    },
  ];

  // Función para simular aceptar una cita
  void _aceptarCita(int id, String cliente) {
    // TODO: Llamar al backend para cambiar estado a ACEPTADA
    setState(() {
      _citasPendientes.removeWhere((cita) => cita["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cita de $cliente aceptada'), backgroundColor: Colors.green),
    );
  }

  // Función para simular rechazar una cita
  void _rechazarCita(int id, String cliente) {
    // TODO: Llamar al backend para cambiar estado a RECHAZADA/CANCELADA
    setState(() {
      _citasPendientes.removeWhere((cita) => cita["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cita de $cliente rechazada'), backgroundColor: Colors.redAccent),
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
              // --- HEADER CON BOTÓN ATRÁS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12, width: 1.5),
                        image: const DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 45), // Equilibrio visual para centrar el logo
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- TÍTULO ---
              const Text(
                "Citas Solicitadas",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // --- TARJETA LAVANDA CON LA LISTA ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Cabecera oscura de la tarjeta
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Citas recientemente solicitadas",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),

                        // Lista de Citas
                        Expanded(
                          child: _citasPendientes.isEmpty
                              ? const Center(
                            child: Text("No hay citas pendientes", style: TextStyle(color: Colors.black54, fontSize: 16)),
                          )
                              : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _citasPendientes.length,
                            itemBuilder: (context, index) {
                              final cita = _citasPendientes[index];
                              final isExpanded = _expandedAppointmentId == cita["id"];

                              return _buildCitaCard(cita, isExpanded);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // --- BARRA INFERIOR (Solo visual para mantener coherencia) ---
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET DE LA TARJETA DE CITA ---
  Widget _buildCitaCard(Map<String, dynamic> cita, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            setState(() {
              // Si tocamos la que ya está abierta, la cerramos. Si no, abrimos la nueva.
              _expandedAppointmentId = isExpanded ? null : cita["id"];
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Fecha y Hora
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cita["fecha"],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    Text(
                      cita["hora"],
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: mainColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fila Inferior: Cliente y Servicio
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        cita["cliente"],
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.content_cut, size: 16, color: Colors.black54),
                    const SizedBox(width: 5),
                    Text(
                      cita["servicio"],
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),

                // --- SECCIÓN DESPLEGABLE (Botones Aceptar / Rechazar) ---
                if (isExpanded) ...[
                  const SizedBox(height: 15),
                  const Divider(height: 1),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      // Botón Cancelar
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text("Rechazar"),
                          onPressed: () => _rechazarCita(cita["id"], cita["cliente"]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Botón Aceptar
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text("Aceptar"),
                          onPressed: () => _aceptarCita(cita["id"], cita["cliente"]),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final iconColor = Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: Icon(Icons.home_outlined, color: iconColor, size: 34), onPressed: () => Navigator.pop(context)),
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.calendar_today, color: accentColor, size: 30),
                Positioned(top: 10, child: Text("15", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
            onPressed: () {},
          ),
          IconButton(icon: Icon(Icons.help_outline, color: iconColor, size: 32), onPressed: () {}),
        ],
      ),
    );
  }
}