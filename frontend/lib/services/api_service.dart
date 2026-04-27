import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/api_config.dart';

class ApiService {

  // ==========================================
  // 🔐 1. GESTIÓN DEL TOKEN (NUEVO)
  // ==========================================
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // ESTA ES LA FUNCIÓN MÁGICA: Añade el token a la cabecera si existe
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _obtenerToken();
    if (token != null) {
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token" // <-- La llave VIP de Iván
      };
    } else {
      return {"Content-Type": "application/json"};
    }
  }

  // Revisa si el token ha caducado
  void _verificarExpiracion(http.Response response) {
    if (response.statusCode == 401) {
      cerrarSesion();
      throw Exception("Tu sesión ha caducado. Vuelve a iniciar sesión.");
    }
  }

  // ==========================================
  // 🔓 2. ENDPOINTS PÚBLICOS (Sin Token)
  // ==========================================

  Future<dynamic> login(String email, String password) async {
    final url = "${ApiConfig.baseUrl}/auth/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        // 1. NOMBRES EXACTOS
        body: jsonEncode({"correoElectronico": email, "contrasena": password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // 2. EXTRAEMOS Y GUARDAMOS EL TOKEN
        if (body['token'] != null) {
          await _guardarToken(body['token']); // ¡Pase VIP guardado en el móvil!
        }

        // Devolvemos el JSON entero
        return body;
      } else {
        throw Exception("Credenciales incorrectas");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> registrarUsuario(String nombre, String apellidos, String email, String password, String telefono, String rol) async {
    // ⚠ NUEVA RUTA DE REGISTRO
    final url = "${ApiConfig.baseUrl}/auth/register";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "apellidos": apellidos,
        "correoElectronico": email,
        "contrasena": password,
        "telefono": telefono,
        "rolUsuario": rol
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) return true;
    throw Exception(response.body);
  }

  // ==========================================
  // 🔒 3. ENDPOINTS PROTEGIDOS (Con Token)
  // ==========================================

  Future<void> reservarCita(dynamic cita) async {
    final url = "${ApiConfig.baseUrl}/citas"; // o /citas/reservar según Iván
    try {
      final headers = await _getHeaders(); // Pedimos los headers con el Token
      final response = await http.post(
        Uri.parse(url),
        headers: headers, // Usamos los headers VIP
        body: jsonEncode(cita.toJson()),
      );

      _verificarExpiracion(response);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.body); // Mostramos si el barbero está ocupado
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getHorasOcupadas(int idBarbero, String fecha) async {
    final url = "${ApiConfig.baseUrl}/citas/barbero/$idBarbero/fecha/$fecha";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        final List<dynamic> citasDelDia = jsonDecode(response.body);
        List<String> horasBloqueadas = [];
        for (var cita in citasDelDia) {
          String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();
          if (estado != 'CANCELADA' && estado != 'RECHAZADA' && cita['fechaHoraCita'] != null) {
            String horaMinutos = cita['fechaHoraCita'].split('T')[1].substring(0, 5);
            horasBloqueadas.add(horaMinutos);
          }
        }
        return horasBloqueadas;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMisCitas(int idUsuario) async {
    final url = "${ApiConfig.baseUrl}/citas/historial/$idUsuario";
    try {
      final headers = await _getHeaders();
      print("🔍 Llamando a GET Citas: $url");
      print("🔑 Headers enviados: $headers"); // Para ver si el token viaja bien

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      print("📩 Respuesta del servidor: Código ${response.statusCode}");
      print("📄 Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        // Si el cuerpo está vacío o algo raro, lo controlamos
        if (response.body.isEmpty) return [];
        return jsonDecode(response.body);
      } else if (response.statusCode == 204) {
        // A veces los servidores devuelven 204 (No Content) si no hay citas
        return [];
      }

      // AQUÍ ESTÁ LA MAGIA: Si falla, escupimos el código de error para verlo en el cartelito rojo
      throw Exception("Error ${response.statusCode}: ${response.body}");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getCitasPorBarbero(int idUsuario, String estado) async {
    final url = "${ApiConfig.baseUrl}/citas/barbero/$idUsuario/$estado";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      _verificarExpiracion(response);

      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> actualizarEstadoCita(int idCita, String estado) async {
    final url = "${ApiConfig.baseUrl}/citas/$idCita/estado";
    try {
      final headers = await _getHeaders();
      // Iván dijo: "Body: Texto plano (String) con el nombre del estado."
      final response = await http.put(Uri.parse(url), headers: headers, body: estado);
      _verificarExpiracion(response);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> aceptarCita(int idCita) => actualizarEstadoCita(idCita, "ACEPTADA");
  Future<bool> rechazarCita(int idCita) => actualizarEstadoCita(idCita, "RECHAZADA");

  Future<bool> cancelarCitaDefinitiva(int idCita) async {
    final url = "${ApiConfig.baseUrl}/citas/cancelar/$idCita";
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers);
      _verificarExpiracion(response);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
  // ==========================================
  // ⚙️ 4. GESTIÓN DE SERVICIOS (ADMIN)
  // ==========================================

  // GET: Listar todos los servicios
  Future<List<dynamic>> getServicios() async {
    final url = "${ApiConfig.baseUrl}/servicios";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        // Usamos utf8.decode para evitar problemas con las tildes/ñ en los nombres
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      throw Exception("Error al cargar el catálogo de servicios: $e");
    }
  }

  // POST: Crear nuevo servicio
  // POST: Crear nuevo servicio (VERSIÓN CHIVATA)
  Future<bool> crearServicio(String nombre, double precio) async {
    final url = "${ApiConfig.baseUrl}/servicios";
    try {
      final headers = await _getHeaders();
      print("🔍 Intentando crear servicio en: $url");

      final bodyCodificado = jsonEncode({
        "nombreServicio": nombre,
        "precioServicio": precio
      });
      print("📦 Datos enviados: $bodyCodificado");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: bodyCodificado,
      ).timeout(const Duration(seconds: 10));

      print("📩 Respuesta del servidor: Código ${response.statusCode}");
      print("📄 Cuerpo de la respuesta: ${response.body}");

      _verificarExpiracion(response);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Excepción capturada en Flutter: $e");
      return false;
    }
  }

  // PUT: Actualizar servicio existente
  Future<bool> actualizarServicio(int id, String nombre, double precio) async {
    final url = "${ApiConfig.baseUrl}/servicios/$id";
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          "idServicio": id,
          "nombreServicio": nombre,
          "precioServicio": precio
        }),
      ).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // DELETE: Eliminar servicio
  Future<bool> eliminarServicio(int id) async {
    final url = "${ApiConfig.baseUrl}/servicios/$id";
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 💰 5. FACTURACIÓN E INGRESOS (ADMIN)
  // ==========================================
  Future<Map<String, dynamic>> getResumenFacturacion() async {
    final url = "${ApiConfig.baseUrl}/admin/facturacion/resumen";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw Exception("Error al cargar la facturación");
    } catch (e) {
      throw Exception("Fallo de conexión al cargar ingresos: $e");
    }
  }

  // ==========================================
  // ✂️ 6. ACCIONES DEL BARBERO
  // ==========================================
  Future<bool> finalizarCita(int idCita) async {
    final url = "${ApiConfig.baseUrl}/citas/$idCita/finalizar";
    try {
      final headers = await _getHeaders();
      // Usamos PUT como pide Iván
      final response = await http.put(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 🔑 7. RECUPERACIÓN DE CONTRASEÑA (Públicos)
  // ==========================================
  Future<bool> solicitarRecuperacion(String email) async {
    final url = "${ApiConfig.baseUrl}/auth/solicitar-recuperacion";
    try {
      print("🔍 Solicitando recuperación a: $url");

      final bodyCodificado = jsonEncode({"correoElectronico": email});
      print("📦 Datos enviados: $bodyCodificado");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: bodyCodificado,
      ).timeout(const Duration(seconds: 10));

      print("📩 Respuesta del servidor: Código ${response.statusCode}");
      print("📄 Cuerpo de la respuesta: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error de Flutter: $e");
      return false;
    }
  }

  Future<bool> confirmarRecuperacion(String codigo, String nuevaContrasena) async {
    final url = "${ApiConfig.baseUrl}/auth/confirmar-recuperacion";
    try {
      print("🔍 Confirmando código a: $url");

      final bodyCodificado = jsonEncode({
        "codigo": codigo,
        "nuevaContrasena": nuevaContrasena
      });
      print("📦 Datos enviados (Paso 2): $bodyCodificado");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: bodyCodificado,
      ).timeout(const Duration(seconds: 10));

      print("📩 Respuesta del servidor: Código ${response.statusCode}");
      print("📄 Cuerpo de la respuesta: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error de Flutter: $e");
      return false;
    }
  }

  // ==========================================
  // 👤 PERFIL DE USUARIO
  // ==========================================

  // Obtener los datos del perfil (GET)
  Future<Map<String, dynamic>> getPerfil() async {
    final url = "${ApiConfig.baseUrl}/perfil";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw Exception("Error al cargar perfil");
    } catch (e) {
      throw Exception("Fallo de conexión al perfil: $e");
    }
  }

  // Actualizar los datos del perfil (PUT)
  Future<bool> actualizarPerfil(String nombre, String apellidos, String telefono) async {
    final url = "${ApiConfig.baseUrl}/perfil";
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        "nombre": nombre,
        "apellidos": apellidos,
        "telefono": telefono
      });

      final response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: body
      ).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<bool> subirImagenPerfil(File imageFile) async {
    final url = "${ApiConfig.baseUrl}/perfil/imagen";
    try {
      // 1. Obtenemos los headers usando tu función que YA funciona.
      final headers = await _getHeaders();
      final authHeader = headers['Authorization']; // Extrae el "Bearer ey..."

      // Si por algún motivo sigue vacío, detenemos la ejecución para no dar falsos errores.
      if (authHeader == null || authHeader.trim().isEmpty) {
        print("🚨 ERROR CRÍTICO: _getHeaders() no devolvió un token válido.");
        return false;
      }

      // 2. Creamos la petición Multipart
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // 3. Le inyectamos el Token EXACTO que usan las demás peticiones
      request.headers['Authorization'] = authHeader;
      // Este header a veces es necesario para APIs en Spring Boot con Multipart
      request.headers['Accept'] = "application/json";

      // 4. Adjuntamos la imagen. Usamos 'file' por ser el estándar en Spring.
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Iván DEBE tener @RequestParam("file") en su Controller
        imageFile.path,
      ));

      // 5. Enviamos la petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("📩 STATUS FOTO: ${response.statusCode}");
      print("📄 BODY FOTO: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error de conexión en subida de foto: $e");
      return false;
    }
  }
}