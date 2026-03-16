import 'package:flutter/material.dart';

class EarningsBarberScreen extends StatefulWidget {
  const EarningsBarberScreen({super.key});

  @override
  State<EarningsBarberScreen> createState() => _EarningsBarberScreenState();
}

class _EarningsBarberScreenState extends State<EarningsBarberScreen> {
  // Datos de prueba  - En el futuro los traeremos del ApiService
  final List<Map<String, dynamic>> _ingresosDelDia = [
    {"servicio": "Mechas", "precio": "25,00 €", "duracion": "45 min", "hora": "10:00"},
    {"servicio": "Mechas color", "precio": "35,00 €", "duracion": "60 min", "hora": "11:30"},
    {"servicio": "Pelo blanco", "precio": "50,00 €", "duracion": "90 min", "hora": "13:00"},
    {"servicio": "Corte Clásico", "precio": "12,00 €", "duracion": "30 min", "hora": "16:00"},
    {"servicio": "Degradado", "precio": "15,00 €", "duracion": "40 min", "hora": "17:00"},
    {"servicio": "Mechas", "precio": "25,00 €", "duracion": "45 min", "hora": "18:30"},
  ];

  @override
  Widget build(BuildContext context) {
    // Calculamos el total para ponerlo en el encabezado (opcional, pero queda genial)
    double total = 0;
    for (var ingreso in _ingresosDelDia) {
      // Extraemos solo el número (ej: de "25,00 €" sacamos 25.0)
      String precioLimpio = ingreso["precio"].replaceAll(" €", "").replaceAll(",", ".");
      total += double.tryParse(precioLimpio) ?? 0;
    }

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
                    // Botón de volver y Logo en el centro
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
                              Text(
                                "+ ${total.toStringAsFixed(2).replaceAll('.', ',')} €",
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- LISTA DE INGRESOS ---
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _ingresosDelDia.length,
                          itemBuilder: (context, index) {
                            final ingreso = _ingresosDelDia[index];
                            return _buildIncomeItemCard(
                              serviceName: ingreso["servicio"],
                              price: ingreso["precio"],
                              duration: ingreso["duracion"],
                              time: ingreso["hora"],
                            );
                          },
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
                        onPressed: () {
                          // Navegar al Home
                          Navigator.pop(context);
                        },
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
        color: Colors.grey.shade50, // Fondo casi blanco
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200), // Borde sutil
      ),
      child: Row(
        children: [
          // Columna Izquierda: Información
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

          // Columna Derecha: Monto (Verde elegante)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.green.shade50, // Fondo verde muy sutil
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
                          fontWeight: FontWeight.w900, // Letra muy gruesa para el dinero
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