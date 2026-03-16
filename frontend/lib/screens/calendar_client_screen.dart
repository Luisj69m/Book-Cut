import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'services_client_screen.dart';

class CalendarClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final int idCliente; // <--  AÑADIMOS LA VARIABLE PARA EL TESTIGO

  const CalendarClientScreen({
    super.key,
    this.barberiaId = 1,
    this.barberiaNombre = "Barbería",
    required this.idCliente, // <--  LO HACEMOS OBLIGATORIO
  });

  @override
  State<CalendarClientScreen> createState() => _CalendarClientScreenState();
}

class _CalendarClientScreenState extends State<CalendarClientScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  bool _isLoadingHours = false;
  List<String> _horasOcupadas = [];

  final List<String> _todasLasHoras = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
    "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"
  ];

  @override
  void initState() {
    super.initState();
    _cargarHorasDisponibles(_selectedDate);
  }

  Future<void> _cargarHorasDisponibles(DateTime fecha) async {
    setState(() {
      _isLoadingHours = true;
      _selectedTime = null;
    });

    try {
      // 1. Formateamos la fecha para Java (ejemplo: "2026-03-30")
      String mes = fecha.month.toString().padLeft(2, '0');
      String dia = fecha.day.toString().padLeft(2, '0');
      String fechaFormateada = "${fecha.year}-$mes-$dia";

      // 2. Llamamos a la base de datos real a través de ApiService
      List<String> horasOcupadasBackend = await ApiService().getHorasOcupadas(widget.barberiaId, fechaFormateada);

      setState(() {
        _horasOcupadas = horasOcupadasBackend; // Guardamos las horas reales
        _isLoadingHours = false;
      });
    } catch (e) {
      print("Error al cargar las horas: $e");
      setState(() {
        _horasOcupadas = []; // Si falla la red, mostramos todo libre por precaución
        _isLoadingHours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.pinkAccent.withOpacity(0.5), width: 2),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black87,
                          radius: 20,
                          child: Icon(Icons.person, color: Colors.white54, size: 25),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 5))
                          ]
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // --- CALENDARIO ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                              ]
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
                                setState(() {
                                  _selectedDate = newDate;
                                });
                                _cargarHorasDisponibles(newDate);
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- SECCIÓN DE HORAS DISPONIBLES ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                              ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Horas disponibles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 15),

                              if (_isLoadingHours)
                                const Center(child: CircularProgressIndicator(color: Colors.black))
                              else
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: _todasLasHoras.where((hora) => !_horasOcupadas.contains(hora)).map((hora) {
                                    bool isSelected = _selectedTime == hora;
                                    return ChoiceChip(
                                      label: Text(
                                          hora,
                                          style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black87,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                          )
                                      ),
                                      selected: isSelected,
                                      selectedColor: Colors.blueAccent.shade700,
                                      backgroundColor: Colors.grey.shade200,
                                      showCheckmark: false,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _selectedTime = selected ? hora : null;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),

                              if (!_isLoadingHours && _todasLasHoras.every((h) => _horasOcupadas.contains(h)))
                                const Text("Lo sentimos, no hay citas disponibles para este día.", style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // --- BOTONES INFERIORES ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTime != null ? Colors.blueAccent.shade700 : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                      onPressed: _selectedTime == null ? null : () {
                        final fechaSola = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
                        final horaSola = _selectedTime!;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesClientScreen(
                              barberiaId: widget.barberiaId,
                              fecha: fechaSola,
                              hora: horaSola,
                              // 3. ¡PASAMOS EL TESTIGO A LA SIGUIENTE PANTALLA!
                              idCliente: widget.idCliente,
                            ),
                          ),
                        );
                      },
                      child: const Text("Continuar", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),

              // --- MENÚ INFERIOR ---
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home_outlined, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                          const Positioned(
                            top: 10,
                            child: Text("15", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}