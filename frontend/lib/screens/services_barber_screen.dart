import 'package:flutter/material.dart';

class ServicesBarberScreen extends StatefulWidget {
  const ServicesBarberScreen({super.key});

  @override
  State<ServicesBarberScreen> createState() => _ServicesBarberScreenState();
}

class _ServicesBarberScreenState extends State<ServicesBarberScreen> {
  // Datos de prueba basados en tu prototipo
  final List<Map<String, dynamic>> _servicios = [
    {"nombre": "Mechas Color", "precio": "35,00 €", "duracion": "60 min"},
    {"nombre": "Mechas", "precio": "25,00 €", "duracion": "45 min"},
    {"nombre": "Pelo blanco", "precio": "50,00 €", "duracion": "90 min"},
    {"nombre": "Corte Clásico", "precio": "12,00 €", "duracion": "30 min"},
    {"nombre": "Arreglo de barba", "precio": "8,00 €", "duracion": "15 min"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Añadimos un botón flotante para "Añadir Servicio"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Lógica para añadir un nuevo servicio
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Añadir servicio en desarrollo")),
          );
        },
        backgroundColor: const Color(0xFF2962FF), // Azul vibrante
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
                      "Mis Servicios",
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
                      // --- TARJETA DE CABECERA OSCURA ---
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
                                "Catálogo de servicios activos",
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text(
                                  "${_servicios.length}",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      // --- LISTA DE SERVICIOS ---
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 10, bottom: 80), // bottom 80 para que el FAB no tape el último
                          physics: const BouncingScrollPhysics(),
                          itemCount: _servicios.length,
                          itemBuilder: (context, index) {
                            final servicio = _servicios[index];
                            return _buildServiceCard(
                              nombre: servicio["nombre"],
                              precio: servicio["precio"],
                              duracion: servicio["duracion"],
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
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 30),
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

  // --- WIDGET PARA CADA TARJETA DE SERVICIO ---
  Widget _buildServiceCard({
    required String nombre,
    required String precio,
    required String duracion,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
          ]
      ),
      child: Row(
        children: [
          // Icono y Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2962FF).withOpacity(0.1), // Azul claro
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.style, size: 16, color: Color(0xFF2962FF)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 5),
                    Text(duracion, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 15),
                    // Etiqueta de precio elegante
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFF381483).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF381483).withOpacity(0.2))
                      ),
                      child: Text(
                        precio,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF381483), fontSize: 13),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          // Botones de acción (Editar / Borrar)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600, size: 20),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () {}, // TODO: Editar servicio
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () {}, // TODO: Borrar servicio
              ),
            ],
          )
        ],
      ),
    );
  }
}