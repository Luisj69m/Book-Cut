import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart';
import 'settings_screen.dart';

class ServicesBarberScreen extends StatefulWidget {
  final int idUsuarioBarbero;

  const ServicesBarberScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<ServicesBarberScreen> createState() => _ServicesBarberScreenState();
}

class _ServicesBarberScreenState extends State<ServicesBarberScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _servicios = [];
  int? _miBarberiaId;

  // Colores corporativos
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);
  final accentLilac = const Color(0xFFB388FF);

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
        if (mounted) {
          setState(() { _servicios = []; _isLoading = false; });
          GlassToast.showWarning(context, "Atención", "Primero debes configurar tu barbería");
        }
        return;
      }

      _miBarberiaId = barberia['id'] ?? barberia['idBarberia'];
      final data = await _apiService.getServiciosPorBarberia(_miBarberiaId!);

      if (mounted) {
        setState(() { _servicios = data; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error", "No se pudieron cargar los servicios: $e");
      }
    }
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1B44).withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: accentLilac.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(isEdit ? Icons.edit_rounded : Icons.add_circle_outline_rounded, color: accentLilac, size: 30),
                  ),
                  const SizedBox(height: 20),
                  Text(
                      isEdit ? "Editar Servicio" : "Nuevo Servicio",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)
                  ),
                  const SizedBox(height: 25),

                  _buildGlassTextField(label: "Nombre del servicio", controller: nombreCtrl),
                  const SizedBox(height: 15),
                  _buildGlassTextField(label: "Precio (€)", controller: precioCtrl, isNumber: true),

                  if (!isEdit) ...[
                    const SizedBox(height: 15),
                    _buildGlassTextField(label: "Duración (minutos)", controller: duracionCtrl, isNumber: true),
                  ],

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentLilac,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            final nombre = nombreCtrl.text.trim();
                            final precio = double.tryParse(precioCtrl.text.replaceAll(',', '.'));
                            final duracion = int.tryParse(duracionCtrl.text.trim());

                            if (nombre.isEmpty || precio == null) {
                              GlassToast.showWarning(context, "Atención", "Revisa que los datos sean correctos");
                              return;
                            }
                            if (!isEdit && (duracion == null || duracion <= 0)) {
                              GlassToast.showWarning(context, "Atención", "La duración debe ser válida");
                              return;
                            }
                            if (!isEdit && _miBarberiaId == null) {
                              GlassToast.showError(context, "Error", "Primero debes configurar tu barbería");
                              return;
                            }

                            Navigator.pop(dialogContext);
                            setState(() => _isLoading = true);

                            try {
                              if (isEdit) {
                                await _apiService.actualizarServicio(servicioEdit['idServicio'], nombre, precio);
                              } else {
                                await _apiService.crearServicio(_miBarberiaId!, nombre, precio, duracion!);
                              }
                              if (mounted) GlassToast.showSuccess(context, "¡Completado!", isEdit ? "Servicio actualizado" : "Servicio creado");
                              _cargarServicios();
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                GlassToast.showError(context, "Error", _limpiarMensaje(e));
                              }
                            }
                          },
                          child: Text(isEdit ? "Guardar" : "Crear", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoBorrar(int idServicio, String nombre) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1B44).withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 30),
                  ),
                  const SizedBox(height: 20),
                  const Text("¿Eliminar Servicio?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text("¿Seguro que deseas borrar '$nombre' permanentemente de tu catálogo?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancelar", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            setState(() => _isLoading = true);
                            try {
                              await _apiService.eliminarServicio(idServicio);
                              if (mounted) GlassToast.showSuccess(context, "Eliminado", "El servicio se borró correctamente");
                              _cargarServicios();
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                GlassToast.showError(context, "Error", _limpiarMensaje(e));
                              }
                            }
                          },
                          child: const Text("Eliminar", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(),
        ),
      ),
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
          bottom: false,
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text("Catálogo", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TARJETA PRINCIPAL (CRISTAL) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            // Cabecera del contenedor
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                        color: accentLilac.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: accentLilac, width: 1.5),
                                        boxShadow: [BoxShadow(color: accentLilac.withOpacity(0.3), blurRadius: 10)]
                                    ),
                                    child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Servicios Ofrecidos", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text("Gestiona tus precios", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: accentLilac.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: accentLilac.withOpacity(0.5), width: 1),
                                    ),
                                    child: Text("${_servicios.length}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                            // Lista scrolleable
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : _servicios.isEmpty
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.content_cut_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 12),
                                  Text("Aún no tienes servicios", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text("Pulsa el botón + para añadir el primero", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                                ],
                              )
                                  : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), // Espacio para navbar flotante
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
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      // BOTÓN FLOTANTE (GLOWING)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accentLilac.withOpacity(0.5), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5))
              ]
          ),
          child: FloatingActionButton(
            backgroundColor: accentLilac,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 0,
            onPressed: () => _mostrarDialogoFormulario(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
            ),
            child: const Icon(Icons.content_cut_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serv['nombreServicio'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 3),
                Text("${serv['precioServicio']} €", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              ],
            ),
          ),
          IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.white.withOpacity(0.6), size: 22),
              onPressed: () => _mostrarDialogoFormulario(servicioEdit: serv)
          ),
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
              onPressed: () => _mostrarDialogoBorrar(serv['idServicio'], serv['nombreServicio'])
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({required String label, required TextEditingController controller, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: accentLilac, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // --- EFECTO CRISTAL EN LA NAVBAR ---
  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, false, () => Navigator.pop(context)),
              _buildNavItem(Icons.content_cut_rounded, true, () {}),


              _buildNavItem(Icons.settings_rounded, false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(idCliente: widget.idUsuarioBarbero),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? accentLilac.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? accentLilac : Colors.white70, size: 26),
      ),
    );
  }
}