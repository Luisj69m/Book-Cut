import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cita_request.dart';

class ServicesClientScreen extends StatefulWidget {
  final int barberiaId;
  final String barberiaNombre;
  final String barberiaDireccion; // <-- ¡NUEVO!
  final String barberiaZona;      // <-- ¡NUEVO!
  final String barberiaDescripcion; // <-- ¡NUEVO!
  final String fecha;
  final String hora;
  final int idCliente;

  const ServicesClientScreen({
    super.key,
    required this.barberiaId,
    required this.barberiaNombre,
    this.barberiaDireccion = "Dirección no disponible", // Por si viene vacío
    this.barberiaZona = "",
    this.barberiaDescripcion = "Barbería Clásica",
    required this.fecha,
    required this.hora,
    required this.idCliente,
  });

  @override
  State<ServicesClientScreen> createState() => _ServicesClientScreenState();
}

class _ServicesClientScreenState extends State<ServicesClientScreen> {
  bool _isLoading = true;
  List<dynamic> _servicios = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    try {
      // ⚠️ Cambiaremos esto en api_service cuando Iván confirme la ruta
      // De momento imaginemos que ya existe getServiciosPorBarberia
      final data = await _apiService.getServiciosPorBarberia(widget.barberiaId);
      setState(() {
        _servicios = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Silenciamos el error temporalmente si no existe la ruta aún
      print('Error al cargar catálogo de esta barbería: $e');
    }
  }

  void _confirmarReserva(int idServicio, String nombreServicio, String precio) async {
    setState(() { _isLoading = true; });

    try {
      List<String> fechaPartes = widget.fecha.split('/');
      int dia = int.parse(fechaPartes[0]);
      int mes = int.parse(fechaPartes[1]);
      int anio = int.parse(fechaPartes[2]);

      List<String> horaPartes = widget.hora.split(':');
      int hora = int.parse(horaPartes[0]);
      int min = int.parse(horaPartes[1]);

      DateTime fechaHoraSeleccionada = DateTime(anio, mes, dia, hora, min);

      // ¡AQUÍ CREAMOS LA RESERVA EXACTAMENTE COMO PIDE IVÁN!
      final reserva = CitaRequest(
        idBarberia: widget.barberiaId,
        idServicio: idServicio,
        fechaHora: fechaHoraSeleccionada,
      );

      // La enviamos al servidor
      await _apiService.reservarCita(reserva);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cita reservada con éxito!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      String mensajeLimpio = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeLimpio),
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
                    Navigator.pop(context);
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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: const Color(0xFF381483),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.black87, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.black87, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop&q=60",
                fit: BoxFit.cover,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- AHORA USAMOS LAS VARIABLES DEL CONSTRUCTOR ---
                  Text(widget.barberiaNombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 5),
                  Text("${widget.barberiaDireccion}, ${widget.barberiaZona}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black87, size: 16),
                      const SizedBox(width: 4),
                      const Text("5,0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Esto también lo podríamos pasar dinámico si el backend lo da
                      Text(" (Reseñas próximamente)", style: TextStyle(color: const Color(0xFFE96D71), fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.barberiaDescripcion, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTab("SERVICIOS", true),
                      _buildTab("RESEÑAS", false),
                      _buildTab("PORTAFOLIO", false),
                      _buildTab("DETALLES", false),
                    ],
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Servicios de este local", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade500),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF381483))),
              ),
            )
          else if (_servicios.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(child: Text("No hay servicios disponibles en este local", style: TextStyle(color: Colors.grey.shade600))),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final servicio = _servicios[index];

                  final int id = servicio['idServicio'];
                  final String nombre = servicio['nombreServicio'] ?? 'Corte';
                  final double precioNum = servicio['precioServicio'] is num
                      ? (servicio['precioServicio'] as num).toDouble()
                      : 0.0;
                  final String precioStr = "${precioNum.toStringAsFixed(2)} €";
                  const String duracion = "30 min"; // Lo dejamos fijo hasta que Iván añada duración a los servicios

                  return Column(
                    children: [
                      _buildServiceItem(id, nombre, precioStr, duracion),
                      if (index < _servicios.length - 1)
                        Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20),
                    ],
                  );
                },
                childCount: _servicios.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.black87 : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        )
      ],
    );
  }

  Widget _buildServiceItem(int id, String nombre, String precio, String duracion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(precio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 2),
              Text(duracion, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF381483),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            onPressed: () => _mostrarDialogoConfirmacion(id, nombre, precio),
            child: const Text("Reservar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}