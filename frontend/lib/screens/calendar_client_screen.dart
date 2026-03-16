import 'package:flutter/material.dart';
import 'services_client_screen.dart'; // Importa esto si no lo tenías

class CalendarClientScreen extends StatefulWidget {
  // AÑADIMOS ESTAS DOS VARIABLES
  final int barberiaId;
  final String barberiaNombre;

  // Actualizamos el constructor
  const CalendarClientScreen({
    super.key,
    this.barberiaId = 1, // Le damos un valor por defecto por si acaso
    this.barberiaNombre = "Barbería",
  });

  @override
  State<CalendarClientScreen> createState() => _CalendarClientScreenState();
}

class _CalendarClientScreenState extends State<CalendarClientScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime; // Guardará la hora elegida (ej: "10:30")

  bool _isLoadingHours = false;
  List<String> _horasOcupadas = []; // Aquí guardaremos las horas que ya están reservadas

  // Generamos todas las horas posibles del día según tu horario
  final List<String> _todasLasHoras = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30",
    "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30"
  ];

  @override
  void initState() {
    super.initState();
    // Cargamos las horas disponibles para el día actual nada más abrir la pantalla
    _cargarHorasDisponibles(_selectedDate);
  }

  // Esta función simula la llamada al backend de Iván para ver qué horas están cogidas
  Future<void> _cargarHorasDisponibles(DateTime fecha) async {
    setState(() {
      _isLoadingHours = true;
      _selectedTime = null; // Si cambia de día, borramos la hora que había seleccionado
    });

    // TODO: En el futuro, aquí llamaremos a ApiService().getHorasOcupadas(fecha)
    await Future.delayed(const Duration(milliseconds: 500)); // Simulamos carga de red

    setState(() {
      // Para la demo, simulamos que los días pares tienen unas horas ocupadas y los impares otras
      if (fecha.day % 2 == 0) {
        _horasOcupadas = ["09:00", "10:30", "12:00", "17:30", "19:00"];
      } else {
        _horasOcupadas = ["09:30", "11:00", "13:30", "16:00", "18:30", "19:30"];
      }
      _isLoadingHours = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // Aseguramos que ocupe todo
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
                      width: 60, // Un poco más pequeño para dar espacio a las horas
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 10, offset: const Offset(0, 5))
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

              // Envolvemos el calendario y las horas en un Scroll por si la pantalla es pequeña
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
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))
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
                                // Al cambiar de día, volvemos a buscar las horas libres
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
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))
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
                                  spacing: 10, // Espacio horizontal entre botones
                                  runSpacing: 10, // Espacio vertical entre botones
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

                              // Si todas las horas de un día estuvieran ocupadas:
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

              // --- BOTONES INFERIORES (Atrás y Continuar) ---
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
                        // Si no hay hora seleccionada, el botón se ve gris apagado
                        backgroundColor: _selectedTime != null ? Colors.blueAccent.shade700 : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      ),
                      // Desactivamos el botón si no hay hora elegida
                      onPressed: _selectedTime == null ? null : () {
                        String fechaFinal = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} a las $_selectedTime";
                        print("Reserva iniciada para: $fechaFinal");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServicesClientScreen(fechaReserva: fechaFinal,
                              barberiaId: widget.barberiaId,),
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