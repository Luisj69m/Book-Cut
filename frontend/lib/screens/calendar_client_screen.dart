import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'services_client_screen.dart';

class CalendarClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final String barberiaDireccion;
  final String barberiaZona;
  final String barberiaDescripcion;
  final int idCliente;

  const CalendarClientScreen({
    super.key,
    this.barberiaId = 1,
    this.barberiaNombre = "Barbería",
    this.barberiaDireccion = "",
    this.barberiaZona = "",
    this.barberiaDescripcion = "",
    required this.idCliente,
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

  // Devuelve true si la hora debe mostrarse como disponible
  bool _horaDisponible(String hora) {
    // 1. Ocupada por el backend
    if (_horasOcupadas.contains(hora)) return false;

    // 2. Si es hoy, ocultamos las horas pasadas
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

      setState(() {
        _horasOcupadas = horasOcupadasBackend;
        _isLoadingHours = false;
      });
    } catch (e) {
      print("Error al cargar las horas: $e");
      setState(() {
        _horasOcupadas = [];
        _isLoadingHours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final horasDisponibles = _todasLasHoras.where(_horaDisponible).toList();

    return Scaffold(
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
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Center(
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── CONTENIDO SCROLLABLE ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ── CALENDARIO ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                          ),
                          child: Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF333333),
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

                      const SizedBox(height: 20),

                      // ── HORAS DISPONIBLES ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Horas disponibles",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 15),

                              if (_isLoadingHours)
                                const Center(child: CircularProgressIndicator(color: Colors.black))
                              else if (horasDisponibles.isEmpty)
                              // Sin horas disponibles (ocupadas + pasadas)
                                Column(
                                  children: [
                                    Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey.shade300),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "No hay horas disponibles para este día.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                                    ),
                                  ],
                                )
                              else
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: horasDisponibles.map((hora) {
                                    final isSelected = _selectedTime == hora;
                                    return ChoiceChip(
                                      label: Text(
                                        hora,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      selected: isSelected,
                                      selectedColor: Colors.blueAccent.shade700,
                                      backgroundColor: Colors.grey.shade200,
                                      showCheckmark: false,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onSelected: (bool selected) {
                                        setState(() => _selectedTime = selected ? hora : null);
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ── BOTONES INFERIORES ──
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0, bottom: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón atrás
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF381483), size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Botón continuar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTime != null
                            ? const Color(0xFF381483)
                            : Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: _selectedTime != null ? 8 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                      ),
                      onPressed: _selectedTime == null
                          ? null
                          : () {
                        final fechaSola = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesClientScreen(
                              barberiaId: widget.barberiaId,
                              barberiaNombre: widget.barberiaNombre,
                              barberiaDireccion: widget.barberiaDireccion,
                              barberiaZona: widget.barberiaZona,
                              barberiaDescripcion: widget.barberiaDescripcion,
                              fecha: fechaSola,
                              hora: _selectedTime!,
                              idCliente: widget.idCliente,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "Continuar",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _selectedTime != null ? Colors.white : Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 22,
                            color: _selectedTime != null ? Colors.white : Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}