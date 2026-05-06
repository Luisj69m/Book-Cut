import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? _miBarberiaId;

  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final correo = prefs.getString('email_usuario') ?? '';
      if (correo.isEmpty) throw Exception("No se encontró sesión activa.");
      final barberia = await _apiService.getBarberiaAsignada(correo);
      if (barberia == null) {
        setState(() { _servicios = []; _isLoading = false; });
        _mostrarSnackBar("Primero debes configurar tu barbería", Colors.orange);
        return;
      }
      _miBarberiaId = barberia['id'] ?? barberia['idBarberia'];
      final data = await _apiService.getServiciosPorBarberia(_miBarberiaId!);
      setState(() { _servicios = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar("Error al cargar servicios: $e", Colors.red);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  String _limpiarMensaje(Object e) {
    final msg = e.toString();
    return msg.startsWith("Exception: ") ? msg.substring(11) : msg;
  }

  void _mostrarDialogoFormulario({Map<String, dynamic>? servicioEdit}) {
    final bool isEdit = servicioEdit != null;
    final nombreCtrl = TextEditingController(text: isEdit ? servicioEdit['nombreServicio'] : '');
    final precioCtrl = TextEditingController(text: isEdit ? servicioEdit['precioServicio'].toString() : '');
    final duracionCtrl = TextEditingController(text: isEdit ? (servicioEdit['duracionMinutos']?.toString() ?? '30') : '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Editar Servicio" : "Nuevo Servicio", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre del servicio", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: precioCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: "Precio (€)", border: OutlineInputBorder())),
            if (!isEdit) ...[
              const SizedBox(height: 15),
              TextField(controller: duracionCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Duración (min)", border: OutlineInputBorder())),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final precio = double.tryParse(precioCtrl.text.replaceAll(',', '.'));
              final duracion = int.tryParse(duracionCtrl.text.trim());
              if (nombre.isEmpty || precio == null) { _mostrarSnackBar("Datos inválidos", Colors.orange); return; }
              if (!isEdit && (duracion == null || duracion <= 0)) { _mostrarSnackBar("Duración inválida", Colors.orange); return; }
              if (!isEdit && _miBarberiaId == null) { _mostrarSnackBar("Primero configura tu barbería", Colors.red); return; }
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                if (isEdit) {
                  await _apiService.actualizarServicio(servicioEdit['idServicio'], nombre, precio);
                } else {
                  await _apiService.crearServicio(_miBarberiaId!, nombre, precio, duracion!);
                }
                _mostrarSnackBar(isEdit ? "Actualizado" : "Creado", Colors.green);
                _cargarServicios();
              } catch (e) {
                setState(() => _isLoading = false);
                _mostrarSnackBar(_limpiarMensaje(e), Colors.red);
              }
            },
            child: Text(isEdit ? "Guardar" : "Crear"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoBorrar(int idServicio, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("¿Eliminar?"),
        content: Text("¿Borrar '$nombre'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _apiService.eliminarServicio(idServicio);
                _cargarServicios();
              } catch (e) {
                setState(() => _isLoading = false);
                _mostrarSnackBar(_limpiarMensaje(e), Colors.red);
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, mainColor, const Color(0xFF1A0A3D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.white, child: Icon(Icons.content_cut, color: mainColor, size: 36)),
                      ),
                    ),
                  ),
                ),
              ),
              const Text("Servicios ofrecidos", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 20),

              // ── TARJETA PRINCIPAL ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // Cabecera degradada
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF381483), Color(0xFF2962FF)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 1.5)),
                                child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Catálogo de servicios", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    SizedBox(height: 4),
                                    Text("Gestiona tus servicios y precios", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                                child: Text("${_servicios.length}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                        // Lista
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : _servicios.isEmpty
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.content_cut_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text("Aún no tienes servicios", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text("Pulsa + para añadir el primero", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                            ],
                          )
                              : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _servicios.length,
                            itemBuilder: (context, index) {
                              final serv = _servicios[index];
                              return _buildServicioCard(serv);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── NAV BAR ──
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, onTap: () => Navigator.pop(context)),
                      _buildNavItem(Icons.content_cut_rounded, active: true, onTap: () {}),
                      _buildNavItem(Icons.settings_rounded, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: () => _mostrarDialogoFormulario(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildServicioCard(Map<String, dynamic> serv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: mainColor.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: mainColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.content_cut_rounded, color: mainColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serv['nombreServicio'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 3),
                Text("${serv['precioServicio']} €", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.edit_rounded, color: Colors.grey.shade500, size: 20), onPressed: () => _mostrarDialogoFormulario(servicioEdit: serv)),
          IconButton(icon: Icon(Icons.delete_outline_rounded, color: accentColor, size: 20), onPressed: () => _mostrarDialogoBorrar(serv['idServicio'], serv['nombreServicio'])),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }
}