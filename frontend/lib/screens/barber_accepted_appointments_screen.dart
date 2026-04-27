import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarberAcceptedAppointmentsScreen extends StatefulWidget {
  final int idUsuarioBarbero;
  const BarberAcceptedAppointmentsScreen({
    super.key,
    required this.idUsuarioBarbero
  });

  @override
  State<BarberAcceptedAppointmentsScreen> createState() => _BarberAcceptedAppointmentsScreenState();
}

class _BarberAcceptedAppointmentsScreenState extends State<BarberAcceptedAppointmentsScreen> {
  int? _expandedAppointmentId;
  List<dynamic> _citasAceptadas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCitasAceptadas();
  }


  Future<void> _cargarCitasAceptadas() async {
    setState(() => _isLoading = true);
    try {
      // AQUÍ: Usamos tu variable real en lugar del 3 fijo
      final citas = await ApiService().getCitasPorBarbero(widget.idUsuarioBarbero, "ACEPTADA");

      setState(() {
        _citasAceptadas = citas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error cargando aceptadas: $e");
    }
  }

  void _finalizarCita(int id, String cliente) async {
    try {
      // AQUÍ: Llamamos a la función especial de facturación
      await ApiService().finalizarCita(id);

      await _cargarCitasAceptadas(); // Refrescar lista
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cobrada con éxito 💰'), backgroundColor: Colors.green)
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent)
      );
    }
  }

  void _cancelarCita(int id, String cliente) async {
    try {
      // Antes: await ApiService().actualizarEstadoCita(id, "CANCELADA");
      await ApiService().cancelarCitaDefinitiva(id); // <-- AHORA (Borra la cita y manda email)

      await _cargarCitasAceptadas();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita cancelada y email enviado'), backgroundColor: Colors.orange));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
    }
  }
  // --- FIN LÓGICA INTACTA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // FONDO DEGRADADO UNIFICADO
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [
              Color(0xFFE96D71), // Rosa/Rojo
              Color(0xFF381483), // Morado oscuro
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER UNIFICADO ---
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
                              ],
                              border: Border.all(color: Colors.white24, width: 2)
                          ),
                          child: ClipOval(
                            child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.white,
                                child: const Icon(Icons.content_cut, color: Color(0xFF381483), size: 40),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Citas Aceptadas",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              // --- CONTENEDOR PRINCIPAL BLANCO UNIFICADO ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- TARJETA DE CABECERA OSCURA ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2A0D68), // Morado oscuro
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tus próximas citas confirmadas",
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.green.shade500, // Verde para indicar "Aceptadas"
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${_citasAceptadas.length}",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // --- LISTA DE CITAS REDISEÑADA ---
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                            : _citasAceptadas.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text("No tienes citas próximas", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        )
                            : RefreshIndicator(
                          onRefresh: _cargarCitasAceptadas,
                          color: const Color(0xFF381483),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _citasAceptadas.length,
                            itemBuilder: (context, index) {
                              final cita = _citasAceptadas[index];

                              // LÓGICA DE MAPEO INTACTA
                              final int idCita = cita["idCita"];
                              final String fechaHora = cita["fechaHoraCita"];
                              final String fechaRaw = fechaHora.split('T')[0];
                              final String hora = fechaHora.split('T')[1].substring(0, 5);
                              final String cliente = cita["clienteReserva"]?["correoElectronico"] ?? "Cliente";
                              final String servicio = cita["servicioContratado"]?["nombreServicio"] ?? "Servicio";

                              // Formateamos la fecha para que se vea bonita (de 2026-03-30 a 30/03/2026)
                              final List<String> fechaPartes = fechaRaw.split('-');
                              final String fechaFormateada = fechaPartes.length == 3 ? "${fechaPartes[2]}/${fechaPartes[1]}/${fechaPartes[0]}" : fechaRaw;

                              final Map<String, dynamic> citaData = {
                                "id": idCita,
                                "fecha": fechaFormateada,
                                "hora": hora,
                                "cliente": cliente,
                                "servicio": servicio
                              };

                              return _buildCitaCard(citaData, _expandedAppointmentId == idCita);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BARRA INFERIOR UNIFICADA ---
              Container(
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 15.0, top: 10),
                  decoration: const BoxDecoration(
                      color: Color(0xFF381483),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        // Icono activo porque estamos en citas
                        icon: const Icon(Icons.calendar_month, color: Color(0xFF2962FF), size: 30),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET DE TARJETA REDISEÑADO ---
  Widget _buildCitaCard(Map<String, dynamic> cita, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: isExpanded ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isExpanded ? const Color(0xFF2962FF).withOpacity(0.5) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: isExpanded ? const Color(0xFF2962FF).withOpacity(0.1) : Colors.black12,
                blurRadius: isExpanded ? 8 : 4,
                offset: const Offset(0, 2)
            )
          ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _expandedAppointmentId = isExpanded ? null : cita["id"]),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera de la tarjeta: Cliente y Estado Verde
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                                cita["cliente"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // Fecha y Hora
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(cita["fecha"], style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                    const SizedBox(width: 15),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(cita["hora"], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2962FF), fontSize: 14)),
                  ],
                ),

                // Contenido Expandible (Botones)
                if (isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.black12),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.content_cut, size: 16, color: Color(0xFF381483)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text("Servicio: ${cita["servicio"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelarCita(cita["id"], cita["cliente"]),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              side: BorderSide(color: Colors.red.shade200),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _finalizarCita(cita["id"], cita["cliente"]),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text("Finalizar", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12)
                          ),
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}