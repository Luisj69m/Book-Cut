import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart';

class ProfileClientScreen extends StatefulWidget {
  const ProfileClientScreen({super.key});

  @override
  State<ProfileClientScreen> createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  final ApiService _apiService = ApiService();

  /// Controladores de los campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // VARIABLES PARA LA IMAGEN
  String? _fotoUrlServidor;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  // Colores corporativos
  final Color deepPurple = const Color(0xFF381483);
  final Color pinkAccent = const Color(0xFFE96D71);
  final Color vibrantPurple = const Color(0xFF6200EA);
  final Color accentLilac = const Color(0xFFB388FF);
  final Color accentBlue = const Color(0xFF2962FF);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- 1. CARGAR DATOS ---
  Future<void> _cargarDatos() async {
    try {
      final datos = await _apiService.getPerfil();
      if (mounted) {
        setState(() {
          _nombreController.text = datos['nombre'] ?? "";
          _apellidosController.text = datos['apellidos'] ?? "";
          _emailController.text = datos['correoElectronico'] ?? "";
          _telefonoController.text = datos['telefono'] ?? "";


          _fotoUrlServidor = datos['urlFotoPerfil'];

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error", "No se pudieron cargar tus datos");
      }
    }
  }

  // --- 2. FLUJO COMPLETO DE IVÁN (SUBIR + ASIGNAR) ---
  Future<void> _seleccionarYSubirImagen() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      // PASO 1: Subir imagen y obtener URL de Supabase
      final String? urlSubida = await _apiService.subirImagenPerfil(File(image.path));

      if (urlSubida != null) {
        // PASO 2: Asignar esa URL al perfil en la base de datos
        final exito = await _apiService.asignarImagenPerfil(urlSubida);

        if (exito && mounted) {
          GlassToast.showSuccess(context, "¡Genial!", "Tu foto de perfil ha sido actualizada.");
          setState(() { _fotoUrlServidor = urlSubida; }); // Mostramos la nueva foto
        } else if (mounted) {
          GlassToast.showError(context, "Error", "Se subió la foto pero no se pudo asignar al perfil.");
        }
      }
    } catch (e) {
      if (mounted) GlassToast.showError(context, "Fallo técnico", e.toString().replaceAll('Exception: ', ''));
      print("Error subiendo foto de perfil: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. GUARDAR DATOS TEXTUALES ---
  Future<void> _guardarPerfil() async {
    if (_nombreController.text.isEmpty) {
      GlassToast.showWarning(context, "Atención", "El nombre es obligatorio para actualizar tu perfil");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exitoDatos = await _apiService.actualizarPerfil(
        _nombreController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (exitoDatos) {
          GlassToast.showSuccess(context, "¡Perfil actualizado!", "Tus datos se han guardado correctamente");
        } else {
          GlassToast.showError(context, "Error", "No se pudieron guardar los cambios");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Fallo de conexión", "Comprueba tu conexión a internet");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [pinkAccent, deepPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER CRISTALINO ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                    ),
                    const SizedBox(width: 15),
                    const Text("Mi Perfil", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // --- CUERPO PRINCIPAL ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    children: [
                      // --- AVATAR GLOWING INTERACTIVO ---
                      Center(
                        child: GestureDetector(
                          onTap: _seleccionarYSubirImagen,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130, height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                  border: Border.all(color: accentLilac.withOpacity(0.6), width: 2.5),
                                  boxShadow: [BoxShadow(color: vibrantPurple.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)],
                                ),
                                child: ClipOval(
                                  child: _fotoUrlServidor != null && _fotoUrlServidor!.isNotEmpty
                                      ? Image.network(_fotoUrlServidor!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, size: 70, color: Colors.white.withOpacity(0.8)))
                                      : Icon(Icons.person, size: 70, color: Colors.white.withOpacity(0.8)),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: accentBlue, shape: BoxShape.circle, border: Border.all(color: deepPurple, width: 3)),
                                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // --- FORMULARIO ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [Icon(Icons.manage_accounts_rounded, color: accentLilac, size: 22), const SizedBox(width: 8), const Text("Datos Personales", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                                const SizedBox(height: 25),
                                _buildGlassTextField(label: "Nombre", icono: Icons.person_outline, controller: _nombreController),
                                const SizedBox(height: 20),
                                _buildGlassTextField(label: "Apellidos", icono: Icons.badge_outlined, controller: _apellidosController),
                                const SizedBox(height: 20),
                                _buildGlassTextField(label: "Teléfono", icono: Icons.phone_outlined, controller: _telefonoController, keyboardType: TextInputType.phone),
                                const SizedBox(height: 20),
                                _buildGlassTextField(label: "Correo Electrónico", icono: Icons.lock_outline_rounded, controller: _emailController, readOnly: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildGlowingVibrantButton("Guardar Cambios", _guardarPerfil),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({required String label, required IconData icono, required TextEditingController controller, bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: readOnly ? Colors.white54 : accentLilac)),
        const SizedBox(height: 8),
        Opacity(
          opacity: readOnly ? 0.6 : 1.0,
          child: TextField(
            controller: controller, readOnly: readOnly, keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500), cursorColor: Colors.white,
            decoration: InputDecoration(
              prefixIcon: Icon(icono, color: Colors.white.withOpacity(0.5), size: 20), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: readOnly ? Colors.transparent : Colors.white.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: readOnly ? Colors.transparent : accentLilac)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowingVibrantButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity, height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: vibrantPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 5))]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: vibrantPurple, foregroundColor: Colors.white, elevation: 0, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.save_rounded, color: Colors.white, size: 20), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}