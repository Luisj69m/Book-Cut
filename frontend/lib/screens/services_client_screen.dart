import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cita_request.dart';

class ServicesClientScreen extends StatefulWidget {
  final int barberiaId;
  final String fecha;
  final String hora;
  final int idCliente; // <-- 1. AÑADIDO EL HUECO PARA RECIBIR EL ID

  const ServicesClientScreen({
    super.key,
    required this.barberiaId,
    required this.fecha,
    required this.hora,
    required this.idCliente, // <-- 2. LO HACEMOS OBLIGATORIO
  });

  @override
  State<ServicesClientScreen> createState() => _ServicesClientScreenState();
}

class _ServicesClientScreenState extends State<ServicesClientScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _servicios = [
    {"id": 1, "nombre": "Corte Clásico", "precio": "12,00 €", "duracion": "30 min"},
    {"id": 2, "nombre": "Degradado y barba", "precio": "18,00 €", "duracion": "45 min"},
    {"id": 3, "nombre": "Arreglo de barba", "precio": "8,00 €", "duracion": "15 min"},
    {"id": 4, "nombre": "Corte a tijera", "precio": "14,00 €", "duracion": "40 min"},
  ];

  void _confirmarReserva(int idServicio, String nombreServicio, String precio) async {
    setState(() { _isLoading = true; });

    try {
      // 1. Parseamos la fecha dd/MM/yyyy y la hora HH:mm
      List<String> fechaPartes = widget.fecha.split('/');
      int dia = int.parse(fechaPartes[0]);
      int mes = int.parse(fechaPartes[1]);
      int anio = int.parse(fechaPartes[2]);

      List<String> horaPartes = widget.hora.split(':');
      int hora = int.parse(horaPartes[0]);
      int min = int.parse(horaPartes[1]);

      DateTime fechaHoraSeleccionada = DateTime(anio, mes, dia, hora, min);

      // 2. Creamos el objeto de petición usando tu ID real
      final reserva = CitaRequest(
        idCliente: widget.idCliente, // <-- 3. ¡ADIÓS AL 1 MANUAL! USAMOS TU ID
        idBarbero: widget.barberiaId,
        idServicio: idServicio,
        fechaHora: fechaHoraSeleccionada,
      );

      // 3. Enviamos al ApiService
      await ApiService().reservarCita(reserva);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita reservada con éxito!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Volvemos al inicio tras el éxito
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fallo al reservar: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  void _mostrarDialogoConfirmacion(int idServicio, String nombreServicio, String precio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
              const SizedBox(height: 15),
              const Text("Confirmar Reserva", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Text("Servicio: $nombreServicio", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              Text("Fecha: ${widget.fecha} - ${widget.hora}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Importe: $precio", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF381483),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Cierra el BottomSheet
                    _confirmarReserva(idServicio, nombreServicio, precio);
                  },
                  child: const Text("Confirmar y Finalizar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Servicios Disponibles", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Lista de servicios
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                      : ListView.builder(
                    padding: const EdgeInsets.all(25),
                    itemCount: _servicios.length,
                    itemBuilder: (context, index) {
                      final servicio = _servicios[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF381483).withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.content_cut, color: Color(0xFF381483)),
                          ),
                          title: Text(servicio["nombre"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text("Duración: ${servicio["duracion"]}"),
                          trailing: Text(servicio["precio"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          onTap: () => _mostrarDialogoConfirmacion(servicio["id"], servicio["nombre"], servicio["precio"]),
                        ),
                      );
                    },
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