import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // --- 1. CARGAR DATOS DESDE EL BACKEND ---
  Future<void> _cargarDatos() async {
    try {
      final datos = await _apiService.getPerfil();
      setState(() {
        _nombreController.text = datos['nombre'] ?? "";
        _apellidosController.text = datos['apellidos'] ?? "";
        _emailController.text = datos['correoElectronico'] ?? "";
        _telefonoController.text = datos['telefono'] ?? "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar("Error al cargar datos", Colors.redAccent);
    }
  }

  // --- 2. GUARDAR DATOS ---
  Future<void> _guardarPerfil() async {
    if (_nombreController.text.isEmpty) {
      _mostrarSnackBar("El nombre es obligatorio", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool exitoDatos = await _apiService.actualizarPerfil(
        _nombreController.text.trim(),
        _apellidosController.text.trim(),
        _telefonoController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (exitoDatos) {
        _mostrarSnackBar("¡Perfil actualizado!", Colors.green);
      } else {
        _mostrarSnackBar("Error al guardar los cambios", Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarSnackBar("Fallo en la conexión", Colors.red);
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
              // --- HEADER ---
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

              // --- CONTENEDOR BLANCO ---
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF381483)))
                          : _buildFormulario(),
                    ),

                    // AVATAR ESTÁTICO (Sin cámara ni botones)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                          ],
                        ),
                        child: const ClipOval(
                          child: Icon(Icons.person, size: 80, color: Color(0xFF381483)),
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
        const Center(
          child: Text("Información Personal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF381483))),
        ),
        const SizedBox(height: 35),
        _buildTextField(label: "Nombre", icono: Icons.person_outline, controller: _nombreController),
        const SizedBox(height: 20),
        _buildTextField(label: "Apellidos", icono: Icons.badge_outlined, controller: _apellidosController),
        const SizedBox(height: 20),
        _buildTextField(label: "Correo Electrónico", icono: Icons.email_outlined, controller: _emailController, isEmail: true, readOnly: true),
        const SizedBox(height: 20),
        _buildTextField(label: "Teléfono", icono: Icons.phone_outlined, controller: _telefonoController, isPhone: true),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            onPressed: _guardarPerfil,
            child: const Text("Guardar Cambios", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required IconData icono, required TextEditingController controller, bool isEmail = false, bool isPhone = false, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.name),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icono, color: readOnly ? Colors.grey : const Color(0xFF381483)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: readOnly ? Colors.transparent : Colors.grey.shade200, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: readOnly ? Colors.transparent : const Color(0xFF381483), width: 2)),
      ),
    );
  }
}