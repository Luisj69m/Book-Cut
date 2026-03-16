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

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  // --- LÓGICA INTACTA ---
  Future<void> _cargarCitas() async {
    setState(() => _isLoading = true);
    try {
      final citasCargadas = await _apiService.getCitasPorBarbero(widget.idUsuarioBarbero, "PENDIENTE");
      setState(() {
        _citas = citasCargadas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Error al cargar citas: $e", Colors.red);
    }
  }

  void _botonAceptar(int idCita) async {
    bool exito = await _apiService.aceptarCita(idCita);
    if (exito) {
      setState(() {
        _citas.removeWhere((cita) => (cita['idCita'] ?? cita['id']) == idCita);
      });
      _mostrarMensaje("¡Cita aceptada con éxito!", Colors.green);
    } else {
      _mostrarMensaje("Error al aceptar la cita", Colors.red);
    }
  }

  void _botonRechazar(int idCita) async {
    bool exito = await _apiService.rechazarCita(idCita);
    if (exito) {
      setState(() {
        _citas.removeWhere((cita) => (cita['idCita'] ?? cita['id']) == idCita);
      });
      _mostrarMensaje("Cita rechazada", Colors.orange);
    } else {
      _mostrarMensaje("Error al rechazar la cita", Colors.red);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
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
          bottom: false, // Dejamos que el contenedor blanco baje hasta el final
          child: Column(
            children: [
              // --- HEADER UNIFICADO (Flechita + Logo + Título) ---
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
                      "Citas Solicitadas",
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
                      // --- TARJETA DE CABECERA OSCURA UNIFICADA ---
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
                                "Solicitudes pendientes de confirmar",
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.orange.shade400, // Naranja para indicar "Pendiente"
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${_citas.length}",
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
                            : _citas.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text("No tienes solicitudes pendientes", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        )
                            : RefreshIndicator(
                            onRefresh: _cargarCitas,
                            color: const Color(0xFF381483),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _citas.length,
                              itemBuilder: (context, index) {
                                final cita = _citas[index];

                                // LÓGICA DE EXTRACCIÓN
                                final int idActual = cita['idCita'] ?? cita['id'];
                                final cliente = cita['clienteReserva']?['nombre'] ?? "Cliente";
                                final servicio = cita['servicioContratado']?['nombreServicio'] ?? cita['servicioContratado']?['nombre'] ?? "Corte (Estándar)";

                                String fechaRaw = cita['fechaHoraCita'] ?? "";
                                String fechaFormateada = "Sin fecha";
                                try {
                                  if (fechaRaw.isNotEmpty) {
                                    DateTime dt = DateTime.parse(fechaRaw);
                                    String dia = dt.day.toString().padLeft(2, '0');
                                    String mes = dt.month.toString().padLeft(2, '0');
                                    String anio = dt.year.toString();
                                    String hora = dt.hour.toString().padLeft(2, '0');
                                    String min = dt.minute.toString().padLeft(2, '0');
                                    fechaFormateada = "$dia/$mes/$anio a las $hora:$min";
                                  }
                                } catch (e) {
                                  fechaFormateada = fechaRaw;
                                }

                                // NUEVO DISEÑO DE LA TARJETA INTERIOR
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey.shade200),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                      ]
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Información de la cita
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Icono de perfil genérico
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF381483).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person, color: Color(0xFF381483), size: 28),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(cliente, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                                const SizedBox(height: 5),
                                                Text(servicio, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                                    const SizedBox(width: 5),
                                                    Text(fechaFormateada, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),
                                      const Divider(height: 1, color: Colors.black12),
                                      const SizedBox(height: 20),

                                      // Botones de acción rediseñados
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _botonRechazar(idActual),
                                              style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red.shade600,
                                                  side: BorderSide(color: Colors.red.shade200),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12)
                                              ),
                                              child: const Text("Rechazar", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _botonAceptar(idActual),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF2962FF), // Azul vibrante
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  padding: const EdgeInsets.symmetric(vertical: 12)
                                              ),
                                              child: const Text("Aceptar Cita", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            )
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
}