import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cita_request.dart';
import '../utils/api_config.dart'; // Importamos el archivo que acabamos de crear

class ApiService {

  // 0. Iniciar Sesión (Login)
  // 0. Iniciar Sesión (Login) con chivato
  Future<Map<String, dynamic>> login(String email, String password) async {
    print("Intentando LOGIN con email: $email"); // Chivato 1

    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": email,
        "contrasenaUsuario": password
      }),
    );

    // Chivato 2: ¿Qué nos contesta el servidor de Iván?
    print("Respuesta del servidor (Status): ${response.statusCode}");
    print("Respuesta del servidor (Body): ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Le añadimos el status code al error para saber si es un 401, 404, 500...
      throw Exception('Error al iniciar sesión. Código de Java: ${response.statusCode}');
    }
  }

  // --- AÑADIR AL API SERVICE ---
  // Registro de nuevos usuarios
  Future<bool> registrarUsuario(String nombre, String apellidos, String email, String password, String telefono, String rol) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registrar),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "apellidos": apellidos,
        "telefono": telefono,
        "correoElectronico": email,
        "contrasenaUsuario": password,
        "rolUsuario": rol // ¡Súper importante que le llegue "BARBERO" o "CLIENTE"!
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Error de Java: ${response.body}"); // Esto nos chivará si falta algún campo más
      throw Exception('Error al registrar');
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

  // Añadimos el int barberiaId a los parámetros
  Future<void> reservarCita(String fecha, String hora, String servicio, String precio, int barberiaId) async {
    try {
      List<String> partesFecha = fecha.split('/');
      String dia = partesFecha[0].padLeft(2, '0');
      String mes = partesFecha[1].padLeft(2, '0');
      String anio = partesFecha[2];
      String fechaFormatoJava = "$anio-$mes-${dia}T$hora:00";

      final response = await http.post(
        Uri.parse(ApiConfig.reservarCita),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "clienteReserva": {"idUsuario": 1},

          // AQUÍ ES DONDE HABLAMOS EL IDIOMA DE IVÁN
          // Si su modelo Java espera "barberoAsignado", lo ponemos así.
          // Y le inyectamos la variable barberiaId que viene desde el Home.
          "barberoAsignado": {"idPerfilBarbero": barberiaId},

          "servicioContratado": {"idServicio": 1},
          "fechaHoraCita": fechaFormatoJava,
          "estadoCita": "PENDIENTE"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo de conexión: $e');
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