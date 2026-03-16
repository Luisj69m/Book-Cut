import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/cita_request.dart'; // Importante: tu modelo de reserva

class ApiService {

  // ==========================================
  // 0. AUTENTICACIÓN Y REGISTRO
  // ==========================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correoElectronico": email,
        "contrasenaUsuario": password
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión: ${response.statusCode}');
    }
  }

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
        "rolUsuario": rol
      }),
    );

    return (response.statusCode == 200 || response.statusCode == 201);
  }

  // ==========================================
  // 1. FUNCIONES DEL CLIENTE
  // ==========================================

  Future<List<dynamic>> getBarberos() async {
    final response = await http.get(Uri.parse(ApiConfig.barberos));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los barberos');
    }
  }

  /// Reserva una cita usando tu clase CitaRequest (incluye identificador_cliente)
  Future<void> reservarCita(CitaRequest cita) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reservarCita),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(cita.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error en reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al reservar: $e');
    }
  }

  Future<List<dynamic>> getMisCitas(int idUsuario) async {
    final url = ApiConfig.misCitas(idUsuario);
    print("--- 🕵️‍♂️ PIDIENDO CITAS DEL CLIENTE (ID: $idUsuario) ---");
    print("URL a la que llamamos: $url");

    try {
      final response = await http.get(Uri.parse(url));

      print("Código de estado devuelto: ${response.statusCode}");
      print("Respuesta bruta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(" Error: El servidor no devolvió 200.");
        return [];
      }
    } catch (e) {
      print(" Error de conexión o de Flutter: $e");
      return [];
    }
  }

  /// Recupera las horas que ya están reservadas para un barbero en un día concreto
  Future<List<String>> getHorasOcupadas(int idBarbero, String fecha) async {
    // Usamos EXACTAMENTE el endpoint que ha confirmado Iván
    final String url = "${ApiConfig.baseUrl}/citas/barbero/$idBarbero/fecha/$fecha";

    print("--- 🕵️‍♂️ COMPROBANDO HORAS OCUPADAS ---");
    print("URL a la que llamamos: $url");

    try {
      final response = await http.get(Uri.parse(url));

      print("Código de respuesta: ${response.statusCode}");
      print("Citas de ese día devueltas por el servidor: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> citasDelDia = jsonDecode(response.body);
        List<String> horasBloqueadas = [];

        for (var cita in citasDelDia) {
          String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();

          // Solo bloqueamos la hora si la cita está PENDIENTE o ACEPTADA
          // (Si está CANCELADA o RECHAZADA, el hueco vuelve a estar libre para otros)
          if (estado != 'CANCELADA' && estado != 'RECHAZADA' && cita['fechaHoraCita'] != null) {
            // La fecha de Java viene como "2026-03-30T11:30:00"
            // Cortamos por la 'T' para quedarnos con "11:30:00" y luego cogemos solo los 5 primeros caracteres ("11:30")
            String horaMinutos = cita['fechaHoraCita'].split('T')[1].substring(0, 5);
            horasBloqueadas.add(horaMinutos);
          }
        }

        print(" Horas que se van a ocultar en la app: $horasBloqueadas");
        return horasBloqueadas;
      } else {
        // Si no hay citas o da error 404 (no encontrado), devolvemos lista vacía (todo libre)
        return [];
      }
    } catch (e) {
      print(" Error consultando disponibilidad: $e");
      return [];
    }
  }

  // ==========================================
  // 2. FUNCIONES DEL BARBERO (Lo más importante ahora)
  // ==========================================

  /// Recupera las citas de un barbero según su idUsuario y el estado deseado
  Future<List<dynamic>> getCitasPorBarbero(int idUsuario, String estado) async {
    // Sincronizado con Iván: /api/citas/barbero/{idUsuario}/{ESTADO}
    final String estadoUpper = estado.trim().toUpperCase();
    final url = "${ApiConfig.baseUrl}/citas/barbero/$idUsuario/$estadoUpper";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error al cargar citas de barbero: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Excepción en getCitasPorBarbero: $e");
      throw Exception('Error de conexión con el servidor');
    }
  }

  // --- ACTUALIZAR ESTADO (Aceptada, Rechazada, etc.) ---
  Future<bool> actualizarEstadoCita(int idCita, String nuevoEstado) async {
    // 1. Construimos la URL limpia
    final String url = "${ApiConfig.baseUrl}/citas/$idCita/estado";

    // 2. Limpiamos el texto: sin espacios y siempre en mayúsculas
    final String estadoLimpio = nuevoEstado.trim().toUpperCase();

    print("--- ENVIANDO PETICIÓN PUT ---");
    print("URL: $url");
    print("Cuerpo (Texto Plano): $estadoLimpio");

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          // REQUISITO: Indicar que es texto plano
          'Content-Type': 'text/plain',
        },
        // REQUISITO CRÍTICO: El string directo, SIN jsonEncode()
        body: estadoLimpio,
      );

      // 3. Manejo de la respuesta
      if (response.statusCode == 200) {
        // Como el backend responde un String y no un JSON,
        // NO usamos jsonDecode(). Usamos response.body directamente.
        print("Éxito del servidor: ${response.body}");
        return true;
      } else {
        print("Error del servidor (${response.statusCode}): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de red/conexión: $e");
      return false;
    }
  }
  Future<bool> aceptarCita(int idCita) => actualizarEstadoCita(idCita, "ACEPTADA");

  Future<bool> rechazarCita(int idCita) => actualizarEstadoCita(idCita, "RECHAZADA");

  Future<bool> finalizarCita(int idCita) => actualizarEstadoCita(idCita, "COMPLETADA");
}