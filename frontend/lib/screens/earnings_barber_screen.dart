import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EarningsBarberScreen extends StatefulWidget {
  const EarningsBarberScreen({super.key});

  @override
  State<EarningsBarberScreen> createState() => _EarningsBarberScreenState();
}

class _EarningsBarberScreenState extends State<EarningsBarberScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  double _totalIngresos = 0.0;
  List<dynamic> _citasDetalle = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosFacturacion();
  }

  Future<void> _cargarDatosFacturacion() async {
    setState(() => _isLoading = true);
    try {
      final datos = await _apiService.getResumenFacturacion();

      setState(() {
        // Obtenemos el total y la lista que nos manda Iván
        _totalIngresos = (datos['totalIngresos'] ?? 0.0).toDouble();
        _citasDetalle = datos['citasDetalle'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la facturación: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
              Color(0xFFE96D71), // Rosa/Rojo
              Color(0xFF381483), // Morado oscuro
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER CON LOGO Y TÍTULO ---
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
                      "Panel de ingresos",
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              // --- CONTENEDOR PRINCIPAL BLANCO ---
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
                      // --- TARJETA DE RESUMEN OSCURA ---
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2A0D68), // Morado muy oscuro
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3))
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Ingresos directos de servicios",
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                                  : Text(
                                "+ ${_totalIngresos.toStringAsFixed(2).replaceAll('.', ',')} €",
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- LISTA DE INGRESOS ---
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                            : _citasDetalle.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 10),
                              Text("Aún no hay citas cobradas", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        )
                            : RefreshIndicator(
                          onRefresh: _cargarDatosFacturacion,
                          color: const Color(0xFF381483),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _citasDetalle.length,
                            itemBuilder: (context, index) {
                              final cita = _citasDetalle[index];

                              // Mapeo seguro de los datos que vienen del backend
                              final String servicioNombre = cita["servicioContratado"]?["nombreServicio"] ?? "Servicio";
                              final double precioNum = (cita["servicioContratado"]?["precioServicio"] ?? 0.0).toDouble();
                              final String precioStr = "${precioNum.toStringAsFixed(2).replaceAll('.', ',')} €";

                              // Formateo de fecha y hora
                              final String fechaHoraRaw = cita["fechaHoraCita"] ?? "2024-01-01T00:00:00";
                              final String hora = fechaHoraRaw.contains('T')
                                  ? fechaHoraRaw.split('T')[1].substring(0, 5)
                                  : "--:--";

                              return _buildIncomeItemCard(
                                serviceName: servicioNombre,
                                price: precioStr,
                                duration: "30 min", // Estático por ahora
                                time: hora,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BARRA INFERIOR ---
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
                        icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                      IconButton(
                        // Icono activo porque estamos en ingresos/finanzas
                        icon: const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 30),
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

  // --- WIDGET PARA CADA TARJETA DE INGRESO ---
  Widget _buildIncomeItemCard({
    required String serviceName,
    required String price,
    required String duration,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF381483).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.content_cut, size: 14, color: Color(0xFF381483)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text("$duration • $time", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade100)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "+ $price",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade800
                      )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}