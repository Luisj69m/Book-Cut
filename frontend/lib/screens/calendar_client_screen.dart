import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/cita_request.dart';
import '../utils/glass_toast.dart';

class CalendarClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final String barberiaDireccion;
  final String barberiaZona;
  final String barberiaDescripcion;
  final int idCliente;

  // ✅ NUEVOS PARÁMETROS DEL SERVICIO
  final int idServicio;
  final String nombreServicio;
  final String precioServicio;

  const CalendarClientScreen({
    super.key,
    this.barberiaId = 1,
    this.barberiaNombre = "Barbería",
    this.barberiaDireccion = "",
    this.barberiaZona = "",
    this.barberiaDescripcion = "",
    required this.idCliente,
    required this.idServicio,
    required this.nombreServicio,
    required this.precioServicio,
  });

  @override
  State<CalendarClientScreen> createState() => _CalendarClientScreenState();
}

class _CalendarClientScreenState extends State<CalendarClientScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoadingHours = false;
  List<String> _horasOcupadas = [];

  final ApiService _apiService = ApiService();

  // Colores Corporativos
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color accentLilac = const Color(0xFFB388FF);

  final List<String> _todasLasHoras = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30",
    "16:00", "16:30", "17:00", "17:30", "18:00", "18:30",
    "19:00", "19:30","20:00"
  ];

  @override
  void initState() {
    super.initState();
    _cargarHorasDisponibles(_selectedDate);
  }

  bool _horaDisponible(String hora) {
    if (_horasOcupadas.contains(hora)) return false;

    final ahora = DateTime.now();
    final esHoy = _selectedDate.year == ahora.year &&
        _selectedDate.month == ahora.month &&
        _selectedDate.day == ahora.day;

    if (esHoy) {
      final partes = hora.split(':');
      final minSlot = int.parse(partes[0]) * 60 + int.parse(partes[1]);
      final minAhora = ahora.hour * 60 + ahora.minute;
      if (minSlot <= minAhora) return false;
    }
    return true;
  }

  Future<void> _cargarHorasDisponibles(DateTime fecha) async {
    setState(() {
      _isLoadingHours = true;
      _selectedTime = null;
    });

    try {
      final mes = fecha.month.toString().padLeft(2, '0');
      final dia = fecha.day.toString().padLeft(2, '0');
      final fechaFormateada = "${fecha.year}-$mes-$dia";

      final horasOcupadasBackend = await _apiService.getHorasOcupadas(widget.barberiaId, fechaFormateada);

      if (mounted) {
        setState(() {
          _horasOcupadas = horasOcupadasBackend;
          _isLoadingHours = false;
        });
      }
    } catch (e) {
      print("Error al cargar las horas: $e");
      if (mounted) {
        setState(() {
          _horasOcupadas = [];
          _isLoadingHours = false;
        });
      }
    }
  }

  Map<String, List<String>> _agruparHoras(List<String> horasDisponibles) {
    List<String> manana = [];
    List<String> tarde = [];

    for (String hora in horasDisponibles) {
      final int horaNum = int.parse(hora.split(':')[0]);
      if (horaNum < 14) {
        manana.add(hora);
      } else {
        tarde.add(hora);
      }
    }
    return { "Mañana": manana, "Tarde": tarde };
  }

  // 🔴 LÓGICA DE RESERVA MOVIDA AQUÍ 🔴
  void _confirmarReserva() async {
    // Cerramos el Pop-up primero para no tener problemas de contexto
    Navigator.pop(context);

    // Podrías poner un loading aquí si lo deseas

    try {
      final String fechaSola = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

      int dia = _selectedDate.day;
      int mes = _selectedDate.month;
      int anio = _selectedDate.year;

      List<String> horaPartes = _selectedTime!.split(':');
      int hora = int.parse(horaPartes[0]);
      int min = int.parse(horaPartes[1]);

      DateTime fechaHoraSeleccionada = DateTime(anio, mes, dia, hora, min);

      final reserva = CitaRequest(
        idBarberia: widget.barberiaId,
        idServicio: widget.idServicio,
        fechaHora: fechaHoraSeleccionada,
      );

      await _apiService.reservarCita(reserva).timeout(const Duration(seconds: 6), onTimeout: () {
        return true;
      });

      if (mounted) {
        GlassToast.showSuccess(
            context,
            "¡Reserva confirmada!",
            "Te esperamos el día $fechaSola a las $_selectedTime"
        );
        Navigator.popUntil(context, (route) => route.isFirst); // Volvemos al inicio
      }
    } catch (e) {
      String mensajeLimpio = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        GlassToast.showError(context, "Error en la reserva", mensajeLimpio);
      }
    }
  }

  // 🔴 POP-UP INTACTO MOVIDO AQUÍ 🔴
  void _mostrarDialogoConfirmacion() {
    final String fechaSola = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              ),
              padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: accentLilac.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_rounded, size: 60, color: accentLilac),
                  ),
                  const SizedBox(height: 20),
                  const Text("Resumen de tu cita", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildResumeRow(Icons.content_cut_rounded, "Servicio", widget.nombreServicio),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Colors.white.withOpacity(0.1))),
                        _buildResumeRow(Icons.calendar_today_rounded, "Fecha", "$fechaSola a las $_selectedTime"),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: Colors.white.withOpacity(0.1))),
                        _buildResumeRow(Icons.storefront_rounded, "Lugar", widget.barberiaNombre),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total a pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.7))),
                      Text(widget.precioServicio, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.greenAccent)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentLilac,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _confirmarReserva, // ✅ LLAMA A LA RESERVA DIRECTA
                      child: const Text("Confirmar Reserva", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResumeRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: accentLilac, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final horasDisponibles = _todasLasHoras.where(_horaDisponible).toList();
    final horasAgrupadas = _agruparHoras(horasDisponibles);

    return Scaffold(
      backgroundColor: deepPurple,
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
              // ── HEADER TIPO TARJETA ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              widget.barberiaNombre,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white.withOpacity(0.7), size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.barberiaZona.isNotEmpty ? widget.barberiaZona : "Ubicación seleccionada",
                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ── CONTENEDOR BLANCO (CUERPO) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))
                      ]
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 35),

                              // ── TÍTULO CALENDARIO ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: pinkAccent.withOpacity(0.15), shape: BoxShape.circle),
                                      child: Icon(Icons.calendar_month_rounded, color: pinkAccent, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text("Fecha de la cita", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),

                              // ── TARJETA DEL CALENDARIO ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(color: Colors.grey.shade100, width: 2),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                                  ),
                                  child: Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: deepPurple,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black87,
                                      ),
                                    ),
                                    child: CalendarDatePicker(
                                      initialDate: _selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                      onDateChanged: (DateTime newDate) {
                                        setState(() => _selectedDate = newDate);
                                        _cargarHorasDisponibles(newDate);
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // ── TÍTULO HORAS ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: deepPurple.withOpacity(0.1), shape: BoxShape.circle),
                                      child: Icon(Icons.access_time_rounded, color: deepPurple, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text("Hora disponible", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black87)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // ── GRUPOS DE HORAS ──
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                child: _isLoadingHours
                                    ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: CircularProgressIndicator(color: deepPurple)))
                                    : horasDisponibles.isEmpty
                                    ? _buildEmptyState()
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (horasAgrupadas["Mañana"]!.isNotEmpty)
                                      _buildHourSection("Mañana", Icons.wb_sunny_rounded, horasAgrupadas["Mañana"]!),

                                    if (horasAgrupadas["Tarde"]!.isNotEmpty) ...[
                                      const SizedBox(height: 25),
                                      _buildHourSection("Tarde", Icons.nights_stay_rounded, horasAgrupadas["Tarde"]!),
                                    ]
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),

                      // ── BOTÓN CONFIRMAR (MUESTRA EL POPUP) ──
                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))]
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedTime != null ? deepPurple : Colors.grey.shade200,
                                elevation: _selectedTime != null ? 8 : 0,
                                shadowColor: deepPurple.withOpacity(0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: _selectedTime == null ? null : _mostrarDialogoConfirmacion, // ✅ AHORA ABRE EL DIÁLOGO
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Revisar y Confirmar",
                                    style: TextStyle(
                                        color: _selectedTime != null ? Colors.white : Colors.grey.shade500,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  if (_selectedTime != null) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20)
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildHourSection(String titulo, IconData icon, List<String> horas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(titulo, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: horas.map((hora) {
            final isSelected = _selectedTime == hora;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTime = isSelected ? null : hora);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? deepPurple : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSelected ? deepPurple : Colors.grey.shade200,
                      width: 1.5
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: deepPurple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
                      : [],
                ),
                child: Text(
                  hora,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 15
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 15),
          const Text("Día completo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
          const SizedBox(height: 5),
          Text("No quedan citas disponibles para esta fecha. Por favor, selecciona otro día.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}