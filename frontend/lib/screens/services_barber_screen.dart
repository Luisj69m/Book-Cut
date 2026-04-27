import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServicesBarberScreen extends StatefulWidget {
  const ServicesBarberScreen({super.key});

  @override
  State<ServicesBarberScreen> createState() => _ServicesBarberScreenState();
}

class _ServicesBarberScreenState extends State<ServicesBarberScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _servicios = [];

  final Color bgDarkPurple = const Color(0xFF381483);
  final Color accentPink = const Color(0xFFE96D71);
  final Color accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getServicios();
      setState(() {
        _servicios = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar("Error al cargar servicios: $e", Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _mostrarDialogoFormulario({Map<String, dynamic>? servicioEdit}) {
    final bool isEdit = servicioEdit != null;
    final nombreController = TextEditingController(text: isEdit ? servicioEdit['nombreServicio'] : '');
    final precioController = TextEditingController(text: isEdit ? servicioEdit['precioServicio'].toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? "Editar Servicio" : "Nuevo Servicio", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre del servicio", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Precio (€)", border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final precioRaw = precioController.text.replaceAll(',', '.');
                final precio = double.tryParse(precioRaw);

                if (nombre.isEmpty || precio == null) {
                  _mostrarSnackBar("Datos inválidos", Colors.orange);
                  return;
                }

                Navigator.pop(context);
                setState(() => _isLoading = true);

                bool exito = isEdit
                    ? await _apiService.actualizarServicio(servicioEdit['idServicio'], nombre, precio)
                    : await _apiService.crearServicio(nombre, precio);

                if (exito) {
                  _mostrarSnackBar(isEdit ? "Actualizado" : "Creado", Colors.green);
                  _cargarServicios();
                } else {
                  _mostrarSnackBar("Error al guardar", Colors.red);
                  setState(() => _isLoading = false);
                }
              },
              child: Text(isEdit ? "Guardar" : "Crear"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoBorrar(int idServicio, String nombre) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("¿Eliminar?"),
          content: Text("¿Borrar '$nombre'?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentPink, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                if (await _apiService.eliminarServicio(idServicio)) {
                  _cargarServicios();
                } else {
                  setState(() => _isLoading = false);
                  _mostrarSnackBar("Error al borrar", Colors.red);
                }
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDarkPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [Color(0xFFE96D71), Color(0xFF381483)],
          ),
        ),
        child: SafeArea(
          bottom: false, // Lo ponemos en false para que el menú llegue hasta el fondo
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context)
                    ),
                    const SizedBox(width: 15),
                    const Text("Gestión de Servicios", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // CONTENIDO DE LA LISTA
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                  ),
                  // Importante: ClipRRect para que la lista no muerda los bordes redondeados
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator(color: bgDarkPurple))
                        : ListView.builder(
                      padding: const EdgeInsets.only(top: 20, bottom: 80, left: 20, right: 20), // Bottom padding extra para el botón flotante
                      itemCount: _servicios.length,
                      itemBuilder: (context, index) {
                        final serv = _servicios[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            title: Text(serv['nombreServicio'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${serv['precioServicio']} €", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.black54), onPressed: () => _mostrarDialogoFormulario(servicioEdit: serv)),
                                IconButton(icon: Icon(Icons.delete_outline, color: accentPink), onPressed: () => _mostrarDialogoBorrar(serv['idServicio'], serv['nombreServicio'])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ==========================================
              // TU NUEVO BOTTOM NAV BAR
              // ==========================================
              Container(
                color: Colors.white, // Fondo blanco para empalmar con el contenedor de arriba
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
                        // Icono activo porque estamos en Servicios
                        icon: const Icon(Icons.content_cut, color: Colors.greenAccent, size: 30),
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
              // ==========================================
            ],
          ),
        ),
      ),
      // ==========================================
      // BOTÓN FLOTANTE (AJUSTADO HACIA ARRIBA)
      // ==========================================
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0), // <--- EL TRUCO: Lo empujamos 70 píxeles arriba
        child: FloatingActionButton(
          backgroundColor: accentBlue,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => _mostrarDialogoFormulario(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}