import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/utils/api_config.dart';

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

  bool _isLoading = true;
  File? _imagenPerfil;

  // ¡AQUÍ ESTÁ LA VARIABLE NUEVA!
  String? fotoUrlServidor;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- 1. CARGAR DATOS DESDE EL BACKEND ---
  Future<void> _cargarDatos() async {
    try {
      print("⏳ Pidiendo datos al servidor...");
      final datos = await _apiService.getPerfil();

      print("🕵️‍♂️ DATOS DEL PERFIL RECIBIDOS: $datos");

      setState(() {
        _nombreController.text = datos['nombre'] ?? "";
        _apellidosController.text = datos['apellidos'] ?? "";
        _emailController.text = datos['correoElectronico'] ?? "";
        _telefonoController.text = datos['telefono'] ?? "";

        String? nombreArchivo = datos['urlFotoPerfil'];
        if (nombreArchivo != null && nombreArchivo.isNotEmpty) {

          fotoUrlServidor = "${ApiConfig.baseUrl}/perfil/imagen/$nombreArchivo";
        } else {
          fotoUrlServidor = null;
        }

        _isLoading = false;
      });
    } catch (e) {

      print("❌ ERROR AL CARGAR EL PERFIL: $e");

      setState(() => _isLoading = false);
      _mostrarSnackBar("Error al cargar datos", Colors.redAccent);
    }
  }

  Future<void> _guardarPerfil() async {
    if (_nombreController.text.isEmpty) {
      _mostrarSnackBar("El nombre es obligatorio", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Guardamos los datos de texto (Nombre, Apellidos, Teléfono)
      bool exitoDatos = await _apiService.actualizarPerfil(
        _nombreController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim(),
      );

      // 2. Si hay una foto nueva seleccionada, la subimos
      bool exitoFoto = true;
      if (_imagenPerfil != null) {
        exitoFoto = await _apiService.subirImagenPerfil(_imagenPerfil!);
      }

      setState(() => _isLoading = false);

      if (exitoDatos && exitoFoto) {
        _mostrarSnackBar("¡Perfil y foto actualizados!", Colors.green);
      } else if (exitoDatos) {
        _mostrarSnackBar("Datos guardados, pero hubo un error con la foto", Colors.orange);
      } else {
        _mostrarSnackBar("Error al guardar los cambios", Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar("Fallo en la conexión", Colors.red);
    }
  }

  // --- 3. SELECCIONAR IMAGEN DE LA GALERÍA ---
  Future<void> _seleccionarImagen() async {

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenPerfil = File(pickedFile.path);
      });
      // (Opcional) Aquí llamaríamos a un endpoint para subir la foto
    }



  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: color, behavior: SnackBarBehavior.floating),
      );
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
            colors: [Color(0xFFE96D71), Color(0xFF381483)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER CON BOTÓN ATRÁS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Mi Perfil", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- CONTENEDOR BLANCO CON LA FOTO FLOTANDO ---
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // El fondo blanco curvado
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      ),
                      // Mientras carga, mostramos la ruedita. Si no, el formulario.
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                          : _buildFormulario(),
                    ),

                    // La Foto de Perfil Flotante
                    Positioned(
                      top: 0,
                      child: GestureDetector(
                        onTap: _seleccionarImagen,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.white, width: 5),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                                ],
                              ),
                              child: ClipOval(
                                child: _imagenPerfil != null
                                    ? Image.file(_imagenPerfil!, fit: BoxFit.cover)
                                    : (fotoUrlServidor != null && fotoUrlServidor!.isNotEmpty)
                                    ? Image.network(fotoUrlServidor!, fit: BoxFit.cover)
                                    : Icon(Icons.person, size: 70, color: Colors.grey.shade400),
                              ),
                            ),
                            // Botón de editar (lapicito)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE96D71),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FORMULARIO DE DATOS ---
  Widget _buildFormulario() {
    return ListView(
      padding: const EdgeInsets.only(top: 80, left: 30, right: 30, bottom: 30),
      physics: const BouncingScrollPhysics(),
      children: [
        // Títulos
        const Center(
          child: Text("Información Personal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF381483))),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text("Mantén tus datos actualizados", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ),
        const SizedBox(height: 35),

        // Nombre
        _buildTextField(label: "Nombre", icono: Icons.person_outline, controller: _nombreController),
        const SizedBox(height: 20),

        // Apellidos
        _buildTextField(label: "Apellidos", icono: Icons.badge_outlined, controller: _apellidosController),
        const SizedBox(height: 20),

        // Correo Electrónico (BLOQUEADO: readOnly = true)
        _buildTextField(
            label: "Correo Electrónico",
            icono: Icons.email_outlined,
            controller: _emailController,
            isEmail: true,
            readOnly: true // Para que no se pueda modificar
        ),
        const SizedBox(height: 20),

        // Teléfono
        _buildTextField(label: "Teléfono", icono: Icons.phone_outlined, controller: _telefonoController, isPhone: true),
        const SizedBox(height: 40),

        // Botón de Guardar
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF), // Azul premium
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              shadowColor: const Color(0xFF2962FF).withOpacity(0.5),
            ),
            onPressed: _guardarPerfil,
            child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET REUTILIZABLE PARA LOS CAMPOS DE TEXTO ---
  Widget _buildTextField({
    required String label,
    required IconData icono,
    required TextEditingController controller,
    bool isEmail = false,
    bool isPhone = false,
    bool readOnly = false, // Añadimos esto para controlar si es editable
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.name),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icono, color: readOnly ? Colors.grey : const Color(0xFF381483)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50, // Más oscuro si está bloqueado
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: readOnly ? Colors.transparent : Colors.grey.shade200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFF381483), width: 2),
        ),
      ),
    );
  }
}