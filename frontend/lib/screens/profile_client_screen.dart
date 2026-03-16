import 'package:flutter/material.dart';

class ProfileClientScreen extends StatefulWidget {
  const ProfileClientScreen({super.key});

  @override
  State<ProfileClientScreen> createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  // Controladores para guardar lo que el usuario escriba
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _guardarDatos() {
    // TODO: Conectar con ApiService para actualizar el usuario en BD
    print("Guardando: ${_nombreController.text}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos guardados correctamente'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF381483),
      // resizeToAvoidBottomInset en true (por defecto) permite que el teclado empuje el scroll
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.8),
            radius: 1.5,
            colors: [
              Color(0xFFE96D71),
              Color(0xFF381483),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- BOTÓN DE ATRÁS ---
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // --- ZONA CENTRAL (Logo + Formulario con Scroll) ---
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 1. Logo gigante de fondo (fijo)
                    Positioned(
                      top: 20,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                            ]
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    // 2. Tarjeta blanca flotante (Scrollable por si el teclado sube)
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 150, bottom: 30), // Bajamos la tarjeta para que deje ver el logo
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
                            ]
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField("Nombre", "Coloca tu nombre aquí", _nombreController),
                            const SizedBox(height: 15),

                            _buildInputField("Apellidos", "Coloca tu apellido aquí", _apellidosController),
                            const SizedBox(height: 15),

                            _buildInputField("Email", "info@example.com", _emailController, isEmail: true),
                            const SizedBox(height: 15),

                            _buildInputField("Teléfono", "Coloca tu número de telefono", _telefonoController, isPhone: true),
                            const SizedBox(height: 25),

                            // Botón Guardar (Negro como en el diseño)
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A1A1A), // Negro oscuro
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _guardarDatos,
                                child: const Text("Guardar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- FOOTER (Firma) ---
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "DARKMATTER",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget personalizado para que los campos de texto queden idénticos a tu foto
  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 45, // Altura fija para hacerlos finos y elegantes
          child: TextField(
            controller: controller,
            keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}