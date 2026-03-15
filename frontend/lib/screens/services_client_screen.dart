import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_client_screen.dart'; // Para volver al inicio al terminar

class ServicesClientScreen extends StatefulWidget {
  final String fechaReserva;
  final int barberiaId; // <--- AÑADIMOS ESTO

  const ServicesClientScreen({super.key, required this.fechaReserva, required this.barberiaId});

  @override
  State<ServicesClientScreen> createState() => _ServicesClientScreenState();
}

class _ServicesClientScreenState extends State<ServicesClientScreen> {
  bool _isBooking = false; // Para mostrar ruedita de carga al reservar

  void _confirmarReserva(String nombreServicio, String precio) async {
    setState(() { _isBooking = true; });

    // Separamos la fecha de la hora (Ej: "15/3/2026 a las 10:30")
    List<String> partes = widget.fechaReserva.split(" a las ");
    String soloFecha = partes[0];
    String soloHora = partes[1];

    bool exito = false;
    try {
      // Llamamos al servicio con los 4 datos
      await ApiService().reservarCita(soloFecha, soloHora, nombreServicio, precio, widget.barberiaId);
      exito = true;
    } catch (e) {
      exito = false;
      print("Error capturado: $e"); // Para que veas en consola si falla algo
    }

    if (mounted) {
      setState(() { _isBooking = false; });

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reserva guardada en la base de datos!'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeClientScreen()),
              (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
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
            colors: [
              Color(0xFFE96D71),
              Color(0xFF381483),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selecciona el servicio",
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Cita para el ${widget.fechaReserva}",
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                    child: _isBooking
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF2962FF)),
                          SizedBox(height: 15),
                          Text("Confirmando tu cita...", style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    )
                        : ListView(
                      padding: const EdgeInsets.all(25.0),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const Text("Servicios más populares", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildServiceCard("Degradado", "12,00 €", "30 min", "Corte degradado realizado con máquina y tijera en la parte superior."),
                        _buildServiceCard("Degradado y barba", "15,00 €", "45 min", "Corte degradado con máquina y arreglo de barba con toalla caliente."),
                        _buildServiceCard("Corte Clásico", "11,00 €", "30 min", "El corte clásico se realiza con máquina la parte lateral y la parte..."),
                        const SizedBox(height: 25),
                        const Text("Otros servicios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildServiceCard("Tinte / Mechas", "25,00 €", "60 min", "Decoloración y aplicación de tinte según el estilo deseado."),
                        _buildServiceCard("Arreglo de Barba", "6,00 €", "15 min", "Perfilado y rebajado de barba rápido."),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(String titulo, String precio, String duracion, String descripcion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(precio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(duracion, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    onPressed: () => _confirmarReserva(titulo, precio),
                    child: const Text("Reservar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}