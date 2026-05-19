import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/utils/api_config.dart';
import 'dart:convert';

const String TOKEN_KEY = 'token';
class ApiService {

  // ==========================================
  //  1. GESTIÓN DEL TOKEN (NUEVO)
  // ==========================================
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(TOKEN_KEY, token);
  }

  Future<String?> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
  }

  // ESTA ES LA FUNCIÓN MÁGICA: Añade el token a la cabecera si existe
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _obtenerToken();
    if (token != null) {
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
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
  //  2. ENDPOINTS PÚBLICOS (Sin Token)
  // ==========================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = "${ApiConfig.baseUrl}/api/usuarios/login";

    // 1. Usamos exactamente las mismas llaves que funcionaron en el registro
    final Map<String, dynamic> loginData = {
      "correoElectronico": email,
      "contrasenaUsuario": password
    };

    print(" --- INICIO PETICIÓN LOGIN --- ");
    print(" URL: $url");
    print(" BODY ENVIADO: ${jsonEncode(loginData)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      print(" --- RESPUESTA SERVIDOR --- ");
      print(" STATUS: ${response.statusCode}");
      print(" BODY: ${response.body}");

      if (response.statusCode == 200) {
        // 1. Decodificamos el JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        // 2. Extraemos el token del JSON

        final String? token = data['token'];

        // 3. GUARDAMOS EL TOKEN EN LA CAJA FUERTE DEL MÓVIL
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email_usuario', data['usuario']['correoElectronico']);
          await prefs.setString('rol_usuario', data['usuario']['rolUsuario']);
          await prefs.setInt('id_usuario', data['usuario']['idUsuario']);
          print(" TOKEN GUARDADO CON ÉXITO EN EL MÓVIL");
        } else {
          print(" AVISO: El login fue bien, pero el servidor no envió ningún 'token'.");
        }

        // 4. Devolvemos los datos del usuario (id, rol, etc)
        return data['usuario'];

      } else if (response.statusCode == 401) {
        throw Exception("El correo o la contraseña no son correctos");
      } else {
        throw Exception("Error en el servidor (${response.statusCode})");
      }
    } catch (e) {
      print(" ERROR EN LOGIN: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> registrarUsuario(String nombre, String apellidos, String email, String password, String telefono, String rol) async {

    final url = "${ApiConfig.baseUrl}/api/usuarios/registrar";


    final Map<String, dynamic> bodyAEnviar = {
      "nombre": nombre,
      "apellidos": apellidos,
      "correoElectronico": email,
      "contrasenaUsuario": password,
      "telefono": telefono,
      "rolUsuario": rol
    };

    // Imprimimos antes de enviar
    print(" --- INICIO PETICIÓN FRONTEND --- ");
    print(" URL EXACTA: $url");
    print(" HEADERS EXACTOS: {'Content-Type': 'application/json'}");
    print(" BODY EXACTO: ${jsonEncode(bodyAEnviar)}");
    print("---------------------------------------");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyAEnviar),
      );

      // 3. PRUEBA DEL SERVIDOR
      print(" --- RESPUESTA DEL SERVIDOR --- ");
      print(" STATUS CODE: ${response.statusCode}");
      print(" BODY DEL SERVIDOR: ${response.body}");
      print("--------------------------------------");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      // Lanzamos el error HTTP real
      throw Exception("Error HTTP ${response.statusCode}: ${response.body}");

    } catch (e) {

      print(" --- EXCEPCIÓN INTERNA EN DART --- ");
      print(" TIPO DE ERROR: ${e.runtimeType}");
      print(" DETALLE DEL ERROR: $e");
      print("------------------------------------");

      throw Exception(e.toString());
    }
  }

  // ==========================================
  //  3. ENDPOINTS PROTEGIDOS (Con Token)
  // ==========================================

  // CREAR CITA

  Future<bool> crearCita(int idBarberia, int idServicio, int idBarbero, String fechaHora) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/citas/crear'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "idBarberia": idBarberia,
          "idServicio": idServicio,
          "idBarbero": idBarbero,
          "fechaHoraCita": fechaHora
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }



  Future<List<dynamic>> getMisCitas(int idUsuario) async {
    final url = "${ApiConfig.baseUrl}/api/citas/historial/$idUsuario";
    try {
      final headers = await _getHeaders();
      print(" Llamando a GET Citas: $url");
      print(" Headers enviados: $headers"); // Para ver si el token viaja bien

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      print(" Respuesta del servidor: Código ${response.statusCode}");
      print(" Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        // Si el cuerpo está vacío , lo controlamos
        if (response.body.isEmpty) return [];
        return jsonDecode(response.body);
      } else if (response.statusCode == 204) {
        // A veces los servidores devuelven 204 (No Content) si no hay citas
        return [];
      }


      throw Exception("Error ${response.statusCode}: ${response.body}");
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  //  OBTENER CITAS DEL BARBERO POR ESTADO
  // ==========================================
  Future<List<dynamic>> getCitasPorBarbero(int idUsuario, String estado) async {

    final url = "${ApiConfig.baseUrl}/api/citas/barbero/$idUsuario/$estado";

    print(" Buscando citas (Estado: $estado) en: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 204) {
        return []; // Lista vacía, no hay citas pendientes
      } else {
        print("⚠ Error del servidor cargando citas: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print(" Error en getCitasPorBarbero: $e");
      return [];
    }
  }

  Future<List<dynamic>> getBarberosPorBarberia(int idBarberia) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/barberos/barberia/$idBarberia'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error al cargar barberos: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception('Error en getBarberosPorBarberia: $e');
    }
  }

  // ==========================================
  //  OBTENER HORAS OCUPADAS (Para el calendario del cliente)
  // ==========================================
  Future<List<String>> getHorasOcupadas(int idBarbero, String fecha) async {
    //  ARREGLADO: Añadido el "/api" que faltaba
    final url = "${ApiConfig.baseUrl}/api/citas/barbero/$idBarbero/fecha/$fecha";

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final List<dynamic> citasDelDia = jsonDecode(utf8.decode(response.bodyBytes));
        List<String> horasBloqueadas = [];

        for (var cita in citasDelDia) {
          String estado = (cita['estadoCita'] ?? "").toString().toUpperCase();
          // No bloqueamos las horas de citas canceladas o rechazadas
          if (estado != 'CANCELADA' && estado != 'RECHAZADA' && cita['fechaHoraCita'] != null) {
            String horaMinutos = cita['fechaHoraCita'].split('T')[1].substring(0, 5);
            horasBloqueadas.add(horaMinutos);
          }
        }
        return horasBloqueadas;
      }
      return [];
    } catch (e) {
      print(" Error cargando horas ocupadas: $e");
      return [];
    }
  }

  // ==========================================
  //  OBTENER TODAS LAS CITAS DE UN LOCAL
  // ==========================================

  Future<List<dynamic>> getCitasPorBarberia(int idBarberia) async {
    final url = "${ApiConfig.baseUrl}/api/citas/barberia/$idBarberia";

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 204) {
        return [];
      }
      return [];
    } catch (e) {
      print(" Error en getCitasPorBarberia: $e");
      return [];
    }
  }

  // ==========================================
  //  ACTUALIZAR ESTADO DE LA CITA
  // ==========================================
  Future<bool> actualizarEstadoCita(int idCita, String estado) async {
    //  ARREGLADO: Añadimos el "/api" que faltaba
    final url = "${ApiConfig.baseUrl}/api/citas/$idCita/estado";

    print(" Intentando cambiar cita $idCita a estado: $estado");
    print(" URL: $url");

    try {
      final headers = await _getHeaders();

      headers["Content-Type"] = "text/plain";

      final response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: estado
      ).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      print(" Respuesta servidor: ${response.statusCode}");


      if (response.statusCode == 400) {
        String mensajeError = "Error al actualizar";
        try {
          final Map<String, dynamic> errorMap = jsonDecode(utf8.decode(response.bodyBytes));
          mensajeError = errorMap['mensaje'] ?? errorMap['error'] ?? mensajeError;
        } catch(e) {
          mensajeError = response.body.isNotEmpty ? response.body : mensajeError;
        }
        throw Exception(mensajeError);
      }

      return response.statusCode == 200;
    } catch (e) {
      print(" Error actualizando estado: $e");
      if (e.toString().contains("Exception:")) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    }
  }

  Future<bool> aceptarCita(int idCita) => actualizarEstadoCita(idCita, "ACEPTADA");
  Future<bool> rechazarCita(int idCita) => actualizarEstadoCita(idCita, "RECHAZADA");

  // --- COMPLETAR CITA ---
  // Llama a la ruta genérica de estado
  Future<bool> completarCita(int idCita) => actualizarEstadoCita(idCita, "COMPLETADA");

  // --- CANCELAR CITA ---

  Future<bool> cancelarCitaDefinitiva(int idCita) async {
    final url = "${ApiConfig.baseUrl}/api/citas/cancelar/$idCita";
    print(" Intentando cancelar cita en: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      print(" Respuesta de cancelación: ${response.statusCode}");
      print(" Body completo: ${response.body}");


      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }


      if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> errorMap = jsonDecode(utf8.decode(response.bodyBytes));
          final String mensaje = (errorMap['mensaje'] ?? errorMap['error'] ?? '').toString().toLowerCase();
          if (mensaje.contains('authentication')) {
            print("⚠ cancelación exitosa pero falla el correo.");
            return true; // La cita está cancelada en BD, devolvemos éxito
          }

          throw Exception(errorMap['mensaje'] ?? errorMap['error'] ?? 'No se pudo cancelar la cita');
        } catch (e) {
          if (e.toString().contains('authentication') || e.toString().contains('Authentication')) {
            return true;
          }
          rethrow;
        }
      }

      throw Exception("Error del servidor (${response.statusCode})");
    } catch (e) {
      print(" Error cancelando cita: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
  // ==========================================
  // ⚙ GESTIÓN DE SERVICIOS (ADMIN)
  // ==========================================

  // GET: Listar todos los servicios
  Future<List<dynamic>> getServicios() async {
    final url = "${ApiConfig.baseUrl}/servicios";
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      if (response.statusCode == 200) {

        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      throw Exception("Error al cargar el catálogo de servicios: $e");
    }
  }


  // ==========================================
  //  OBTENER SERVICIOS DE UNA BARBERÍA ESPECÍFICA
  // ==========================================
  Future<List<dynamic>> getServiciosPorBarberia(int idBarberia) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/barberia/$idBarberia";

    print(" Pidiendo servicios para la barbería ID: $idBarberia");
    print(" URL: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);


      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print(" SERVICIOS RECIBIDOS: $data");
        return data;
      } else if (response.statusCode == 204) {
        print("ℹ La barbería $idBarberia no tiene servicios todavía (204).");
        return [];
      } else {
        print(" Error del servidor. Código: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print(" Error cargando servicios de la barbería: $e");
      return [];
    }
  }

  // POST: Crear nuevo servicio en la barbería del trabajador.
  // `duracionMinutos` es OBLIGATORIO: el motor de citas lo usa para detectar solapamientos.

  Future<void> crearServicio(int idBarberia, String nombre, double precio, int duracionMinutos) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/barberia/$idBarberia";
    final headers = await _getHeaders();

    final bodyCodificado = jsonEncode({
      "nombreServicio": nombre,
      "precioServicio": precio,
      "duracionMinutos": duracionMinutos,
    });
    print(" POST crear servicio en: $url");
    print(" Datos enviados: $bodyCodificado");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: bodyCodificado,
    ).timeout(const Duration(seconds: 10));

    print(" Respuesta: ${response.statusCode}");
    print(" Body: ${response.body}");
    _verificarExpiracion(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extraerMensajeError(response, "No se pudo crear el servicio."));
    }
  }

  // PUT: Actualizar servicio existente. Body solo {nombreServicio, precioServicio}.
  Future<void> actualizarServicio(int id, String nombre, double precio) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/actualizar/$id";
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        "nombreServicio": nombre,
        "precioServicio": precio,
      }),
    ).timeout(const Duration(seconds: 10));
    _verificarExpiracion(response);

    if (response.statusCode != 200) {
      throw Exception(_extraerMensajeError(response, "No se pudo actualizar el servicio."));
    }
  }

  // DELETE: Eliminar servicio. Devuelve 400 con mensaje si tiene citas asociadas.
  Future<void> eliminarServicio(int id) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/eliminar/$id";
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
    _verificarExpiracion(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extraerMensajeError(response, "No se pudo eliminar el servicio."));
    }
  }

  // Decodifica el campo "mensaje" del body cuando el backend devuelve un error.
  String _extraerMensajeError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map) {
        final m = body['mensaje'] ?? body['error'];
        if (m is String && m.isNotEmpty) return m;
      }
    } catch (_) {}
    return fallback;
  }

  // ==========================================
  //  5. FACTURACIÓN E INGRESOS (ADMIN)
  // ==========================================

  Future<Map<String, dynamic>> getResumenFacturacion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '${ApiConfig.baseUrl}/api/admin/facturacion/resumen';

      print('--------------------------------------------------');
      print(' CHIVATO FACTURACIÓN: Solicitando resumen...');
      print(' URL: $url');
      print(' Token enviado: ${token.isNotEmpty ? "SÍ" : "NO"}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print(' Status Code: ${response.statusCode}');
      print(' Response Body: ${response.body}');
      print('--------------------------------------------------');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print(' Excepción en getResumenFacturacion: $e');
      throw Exception('Error al obtener facturación: $e');
    }
  }

  // ==========================================
  // ✂ 6. ACCIONES DEL BARBERO
  // ==========================================
  Future<bool> finalizarCita(int idCita) async {
    final url = "${ApiConfig.baseUrl}/citas/$idCita/finalizar";
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      //  ESCUDO ANTI-ERRORES 400
      if (response.statusCode == 400) {
        final Map<String, dynamic> errorMap = jsonDecode(utf8.decode(response.bodyBytes));
        String mensajeError = errorMap['mensaje'] ?? errorMap['error'] ?? 'No puedes completar esta cita todavía';
        throw Exception(mensajeError);
      }

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains("Exception:")) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    }
  }

  // ==========================================
  //  7. RECUPERACIÓN DE CONTRASEÑA (Públicos)
  // ==========================================

  Future<bool> solicitarRecuperacionPassword(String email) async {
    final url = "${ApiConfig.baseUrl}/api/usuarios/solicitar-recuperacion";

    print(" Solicitando recuperación para: $email");

    try {

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, // Le decimos que enviamos JSON
        body: jsonEncode({'correoElectronico': email}),
      ).timeout(const Duration(seconds: 10));

      print(" Respuesta recuperación: ${response.statusCode}");


      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      else if (response.statusCode == 400 || response.statusCode == 404) {
        String mensajeError = "No se pudo solicitar la recuperación";
        try {
          final errorMap = jsonDecode(utf8.decode(response.bodyBytes));
          mensajeError = errorMap['mensaje'] ?? errorMap['error'] ?? mensajeError;
        } catch (_) {
          mensajeError = response.body.isNotEmpty ? response.body : mensajeError;
        }
        throw Exception(mensajeError);
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      print(" Error en recuperación: $e");

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> confirmarRecuperacion(String codigo, String nuevaContrasena) async {
    final url = "${ApiConfig.baseUrl}/api/usuarios/confirmar-recuperacion";
    try {
      final bodyCodificado = jsonEncode({
        "codigo": codigo,
        "nuevaContrasena": nuevaContrasena
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: bodyCodificado,
      ).timeout(const Duration(seconds: 10));

      print(" Respuesta del servidor: Código ${response.statusCode}");
      print(" Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) return true;

      // Intentamos extraer el mensaje de error
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final mensaje = body['mensaje'] ?? body['error'];
        if (mensaje != null) throw Exception(mensaje);
      } catch (_) {}

      throw Exception("Código incorrecto o expirado (${response.statusCode})");

    } catch (e) {
      print(" Error de Flutter: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ==========================================
  //  PERFIL DE USUARIO
  // ==========================================

  // Obtener los datos del perfil (GET)
  Future<Map<String, dynamic>> getPerfil() async {
    try {
      // 1. Sacamos el correo de la caja fuerte
      final prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email_usuario') ?? '';

      if (email.isEmpty) throw Exception("No hay correo guardado en sesión");

      // 2. Montamos la URL exacta
      final url = "${ApiConfig.baseUrl}/api/usuarios/perfil/$email";

      final headers = await _getHeaders();
      print(" --- PEDIENDO PERFIL --- 🔗 URL: $url");

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      print(" STATUS PERFIL: ${response.statusCode}");
      print(" BODY PERFIL: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw Exception("Error del servidor (${response.statusCode})");

    } catch (e) {
      print(" ERROR EN PERFIL: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

// Actualizar los datos del perfil (PUT)
  Future<bool> actualizarPerfil(String nombre, String apellidos, String telefono) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email_usuario') ?? '';

      final url = "${ApiConfig.baseUrl}/api/usuarios/perfil/$email";

      final headers = await _getHeaders();
      final body = jsonEncode({"nombre": nombre, "apellidos": apellidos, "telefono": telefono});

      final response = await http.put(Uri.parse(url), headers: headers, body: body).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> eliminarCuenta(int idCliente) async {


    final url = Uri.parse('${ApiConfig.baseUrl}/api/usuarios/eliminar/$idCliente');

    try {
      //Recuperamos el token JWT que guardamos al hacer Login
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      print(" --- INICIO BORRADO DE CUENTA --- 🗑");
      print(" URL: $url");
      print(" TOKEN ENVIADO: Bearer $token");

      final response = await http.delete(
        url,

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(" --- RESPUESTA SERVIDOR --- ");
      print(" STATUS: ${response.statusCode}");
      print(" BODY: ${response.body}");


      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Error al borrar la cuenta (${response.statusCode})");
      }
    } catch (e) {
      print(" ERROR ELIMINANDO CUENTA: $e");
      // Esto lo capturará tu pantalla de Ajustes para mostrar el SnackBar rojo
      return false;
    }
  }

  // --- OBTENER LOS DATOS DE MI BARBERÍA (GET) ---
  Future<Map<String, dynamic>?> getMiBarberia(int idUsuarioBarbero) async {
    try {
      final url = "${ApiConfig.baseUrl}/api/barberias/mi-barberia/$idUsuarioBarbero";
      final headers = await _getHeaders();

      print(" Pidiendo datos de barbería a: $url");
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 404) {
        // Si devuelve 404 significa que el barbero aún no ha creado su local
        return null;
      }
      return null;
    } catch (e) {
      print(" Error obteniendo barbería: $e");
      return null;
    }
  }

  // --- ACTUALIZAR O CREAR MI BARBERÍA (PUT) ---
  Future<bool> actualizarMiBarberia(int idUsuarioBarbero, Map<String, dynamic> datos) async {
    try {
      final url = "${ApiConfig.baseUrl}/api/barberias/mi-barberia/$idUsuarioBarbero";
      final headers = await _getHeaders();

      print("Enviando datos de barbería a: $url");
      final response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(datos)
      ).timeout(const Duration(seconds: 10));

      print(" Respuesta del servidor: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print(" Error actualizando barbería: $e");
      return false;
    }
  }
  // ==========================================
  //  OBTENER TODAS LAS BARBERÍAS
  // ==========================================
  Future<List<dynamic>> getTodasLasBarberias() async {
    final url = "${ApiConfig.baseUrl}/api/barberias";

    print(" 1. Iniciando petición a Barberías...");
    print(" 2. URL de destino: $url");

    try {
      print(" 3. Preparando Headers (buscando token en memoria)...");
      final headers = await _getHeaders();
      print(" 4. Headers listos. Disparando GET...");

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      print(" 5. ¡Respuesta del servidor recibida!");
      print(" STATUS CODE: ${response.statusCode}");
      print(" BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print(" El servidor devolvió 200 pero la lista está VACÍA.");
          return [];
        }
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      print(" 6. ERROR CATASTRÓFICO en getTodasLasBarberias: $e");
      return [];
    }
  }
  // ==========================================
  //  OBTENER BARBERÍA ASIGNADA AL TRABAJADOR
  // ==========================================
  Future<Map<String, dynamic>?> getBarberiaAsignada(String correoBarbero) async {
    final url = "${ApiConfig.baseUrl}/api/barberias/asignada/$correoBarbero";
    print(" Buscando barbería asignada para el correo: $correoBarbero");
    print(" URL: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print(" DATOS RECIBIDOS: $data");
        return data;
      } else {
        print(" Error del servidor. Código: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(" Error de conexión: $e");
      return null;
    }
  }



  // ─── FUNCIONES PARA IMÁGENES DE BARBERÍA (CORREGIDAS) ───

  Future<String?> subirImagenBarberia(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest(
        'POST',

        Uri.parse('${ApiConfig.baseUrl}/api/imagenes/subir'),
      );

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Añadir el archivo
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('Enviando imagen a ${ApiConfig.baseUrl}/api/imagenes/subir...');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Status code (Subida): ${response.statusCode}');
      print('Response body (Subida): ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        String urlImagen = jsonData['url'];
        print('Imagen subida correctamente: $urlImagen');
        return urlImagen;
      } else {
        print(' Error al subir imagen: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print(' Excepción en subirImagenBarberia: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<bool> asignarImagenABarberia(int idBarberia, String urlImagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var assignResponse = await http.put(

        Uri.parse('${ApiConfig.baseUrl}/api/imagenes/asignar/$idBarberia'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'urlImagen': urlImagen}),
      );

      print('Asignación status: ${assignResponse.statusCode}');
      print('Asignación body: ${assignResponse.body}');

      if (assignResponse.statusCode == 200) {
        print(' Imagen asignada correctamente en BD');
        return true;
      } else {
        print(' Error al asignar imagen en BD');
        return false;
      }
    } catch (e) {
      print(' Excepción en asignarImagenABarberia: $e');
      throw Exception('Error al asignar imagen: $e');
    }
  }


  // ─── 1. SUBIR FOTO DE PERFIL A SUPABASE ───
  Future<String?> subirImagenPerfil(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/imagenes/perfil/subir'),
      );

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var json = jsonDecode(responseData);
        return json['url']; // Nos devuelve la URL directa de Supabase
      } else {
        throw Exception("Error del servidor: $responseData");
      }
    } catch (e) {
      throw Exception('Error al subir foto de perfil: $e');
    }
  }

  // ─── 2. ASIGNAR LA URL AL PERFIL DEL USUARIO ───
  Future<bool> asignarImagenPerfil(String urlImagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/imagenes/perfil/asignar'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'urlFotoPerfil': urlImagen}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al asignar foto de perfil: $e');
    }
  }

}