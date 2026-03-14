import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_request.dart';
import '../utils/api_config.dart'; // Importamos el archivo que acabamos de crear

class ApiService {

  // 0. Iniciar Sesión (Login)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login), // Usamos la variable de Iván
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": email,
        "contrasenaUsuario": password
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Correo o contraseña incorrectos');
    }
  }

  // --- AÑADIR AL API SERVICE ---
  // Registro de nuevos usuarios
  Future<bool> registrarUsuario(String email, String password, String rol) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registrar),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": email,
        "contrasenaUsuario": password,
        "rolUsuario": rol // Aquí le pasaremos "CLIENTE" o "BARBERO"
      }),
    );

    // Si devuelve un 200 (OK) o un 201 (Creado)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error al registrar el usuario en el servidor');
    }
  }

  // 1. Listar Barberos
  Future<List<dynamic>> getBarberos() async {
    final response = await http.get(Uri.parse(ApiConfig.barberos));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los barberos');
    }
  }

  // 2. Listar Servicios
  Future<List<dynamic>> getServicios() async {
    final response = await http.get(Uri.parse(ApiConfig.servicios));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los servicios');
    }
  }

  // --- ÚNICO MÉTODO PARA RESERVAR ---
  Future<void> reservarCita(String fecha, String hora, String servicio, String precio) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reservarCita), // Usamos tu variable de Config
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaCita": fecha,
          "horaCita": hora,
          "servicio": servicio,
          "precio": precio,
          "clienteId": 1, // El ID estático para la demo
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return; // Éxito total
      } else if (response.statusCode == 500) {
        throw Exception('Esta hora ya está reservada');
      } else {
        throw Exception('Error al guardar la cita en el servidor');
      }
    } catch (e) {
      // Si no hay internet o falla Ngrok, relanzamos el error para que la pantalla lo vea
      throw Exception(e.toString().contains('is not a subtype')
          ? 'Error de formato en los datos'
          : 'Error de conexión: Verifica Ngrok');
    }
  }


  // 4. Ver Mis Citas
  Future<List<dynamic>> getMisCitas(int idUsuario) async {
    final response = await http.get(Uri.parse(ApiConfig.misCitas(idUsuario)));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar el historial de citas');
    }
  }

  // 5. Cancelar Cita
  Future<bool> cancelarCita(int idCita) async {
    final response = await http.delete(Uri.parse(ApiConfig.cancelarCita(idCita)));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al cancelar la cita');
    }
  }
}