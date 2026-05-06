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
  // 🔐 1. GESTIÓN DEL TOKEN (NUEVO)
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
        // 1. Decodificamos el JSON que nos manda Iván
        final Map<String, dynamic> data = jsonDecode(response.body);

        // 2. Extraemos el token del JSON
        // (OJO: Asegúrate de que Iván llama a la variable "token" en su backend)
        final String? token = data['token'];

        // 3. GUARDAMOS EL TOKEN EN LA CAJA FUERTE DEL MÓVIL
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email_usuario', data['usuario']['correoElectronico']);
          await prefs.setString('rol_usuario', data['usuario']['rolUsuario']);
          print(" TOKEN GUARDADO CON ÉXITO EN EL MÓVIL");
        } else {
          print("⚠ AVISO: El login fue bien, pero el servidor no envió ningún 'token'.");
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
      "contrasenaUsuario": password, // <-- ¡Corregido!
      "telefono": telefono,
      "rolUsuario": rol
    };

    // 2. LA PRUEBA PARA IVÁN (Imprimimos antes de enviar)
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

      // 3. LA PRUEBA DEL SERVIDOR (Imprimimos lo que responde Render)
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
      // 4. EL DETECTOR DE MENTIRAS (Captura fallos internos de Dart/Flutter)
      print(" --- EXCEPCIÓN INTERNA EN DART --- ");
      print(" TIPO DE ERROR: ${e.runtimeType}");
      print(" DETALLE DEL ERROR: $e");
      print("------------------------------------");

      throw Exception(e.toString());
    }
  }

  // ==========================================
  // 🔒 3. ENDPOINTS PROTEGIDOS (Con Token)
  // ==========================================

  Future<void> reservarCita(dynamic cita) async {
    final url = "${ApiConfig.baseUrl}/api/citas/crear"; // Asegúrate de que esta es la ruta correcta de Iván

    try {
      final headers = await _getHeaders();

      print("🚀 ENVIANDO RESERVA A: $url");
      print("📦 DATOS ENVIADOS: ${jsonEncode(cita.toJson())}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(cita.toJson()),
      );

      print("📥 RESPUESTA SERVIDOR: ${response.statusCode}");
      print("📄 BODY: ${response.body}");

      _verificarExpiracion(response);

      // 🛡️ ESCUDO ANTI-ERRORES MEJORADO (400 y 500)
      if (response.statusCode == 400 || response.statusCode == 500) {
        String mensajeError = "Error desconocido en el servidor";
        final cuerpoRespuesta = utf8.decode(response.bodyBytes);

        try {
          // Intentamos leerlo como JSON (Lo ideal si Iván lo programa así)
          final Map<String, dynamic> errorMap = jsonDecode(cuerpoRespuesta);
          mensajeError = errorMap['mensaje'] ?? errorMap['error'] ?? 'Error de validación al reservar';
        } catch (e) {
          // Si el servidor "escupe" texto plano (como el error que te dio)
          // Atrapamos el texto directamente para no romper el jsonDecode
          mensajeError = cuerpoRespuesta.isNotEmpty ? cuerpoRespuesta : "Error del servidor al procesar la cita";
        }

        // Lanzamos el error hacia la pantalla
        throw Exception(mensajeError);
      }

      // Si no es 200 ni 201, y tampoco es 400 o 500, lanzamos error genérico
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Error del servidor (${response.statusCode})");
      }

    } catch (e) {
      // Limpiamos el prefijo "Exception: " para que el SnackBar quede bonito
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }



  Future<List<dynamic>> getMisCitas(int idUsuario) async {
    final url = "${ApiConfig.baseUrl}/api/citas/historial/$idUsuario";
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

  // ==========================================
  // 📅 OBTENER CITAS DEL BARBERO POR ESTADO
  // ==========================================
  Future<List<dynamic>> getCitasPorBarbero(int idUsuario, String estado) async {
    // 🚨 ARREGLADO: Añadido el "/api" que faltaba en la ruta
    final url = "${ApiConfig.baseUrl}/api/citas/barbero/$idUsuario/$estado";

    print("🔍 Buscando citas (Estado: $estado) en: $url");

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
        print("⚠️ Error del servidor cargando citas: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("🚨 Error en getCitasPorBarbero: $e");
      return [];
    }
  }

  // ==========================================
  // 🕒 OBTENER HORAS OCUPADAS (Para el calendario del cliente)
  // ==========================================
  Future<List<String>> getHorasOcupadas(int idBarbero, String fecha) async {
    // 🚨 ARREGLADO: Añadido el "/api" que faltaba
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
      print("🚨 Error cargando horas ocupadas: $e");
      return [];
    }
  }

  // ==========================================
  // 🏪 (NUEVO) OBTENER TODAS LAS CITAS DE UN LOCAL
  // ==========================================
  // Iván ha creado este endpoint también. Por si en el futuro quieres
  // que el dueño vea TODAS las citas de su local, aquí tienes la función lista:
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
      print("🚨 Error en getCitasPorBarberia: $e");
      return [];
    }
  }

  // ==========================================
  // 🔄 ACTUALIZAR ESTADO DE LA CITA
  // ==========================================
  Future<bool> actualizarEstadoCita(int idCita, String estado) async {
    // 🚨 ARREGLADO: Añadimos el "/api" que faltaba
    final url = "${ApiConfig.baseUrl}/api/citas/$idCita/estado";

    print("🔄 Intentando cambiar cita $idCita a estado: $estado");
    print("🔗 URL: $url");

    try {
      final headers = await _getHeaders();
      // Ojo: Como enviamos un texto plano ("ACEPTADA"), le decimos al servidor que es texto
      headers["Content-Type"] = "text/plain";

      final response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: estado
      ).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      print("📥 Respuesta servidor: ${response.statusCode}");

      // 🛡️ ESCUDO ANTI-ERRORES 400
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
      print("🚨 Error actualizando estado: $e");
      if (e.toString().contains("Exception:")) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      return false;
    }
  }

  Future<bool> aceptarCita(int idCita) => actualizarEstadoCita(idCita, "ACEPTADA");
  Future<bool> rechazarCita(int idCita) => actualizarEstadoCita(idCita, "RECHAZADA");

  // --- COMPLETAR CITA ---
  // Llama a la ruta genérica de estado que hicimos antes
  Future<bool> completarCita(int idCita) => actualizarEstadoCita(idCita, "COMPLETADA");

  // --- CANCELAR CITA ---
  // Iván especificó en su documento (Punto 4) que la cancelación tiene su propia ruta
  Future<bool> cancelarCitaDefinitiva(int idCita) async {
    final url = "${ApiConfig.baseUrl}/api/citas/cancelar/$idCita";
    print("🚫 Intentando cancelar cita en: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      print("📥 Respuesta de cancelación: ${response.statusCode}");

      if (response.statusCode == 400 || response.statusCode == 500) {
        String mensajeError = "Error al cancelar";
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
      print("🚨 Error cancelando cita: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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

  // ==========================================
  // ✂️ OBTENER SERVICIOS DE UNA BARBERÍA ESPECÍFICA
  // ==========================================
  // ==========================================
  // ✂️ OBTENER SERVICIOS DE UNA BARBERÍA ESPECÍFICA
  // ==========================================
  Future<List<dynamic>> getServiciosPorBarberia(int idBarberia) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/barberia/$idBarberia";

    print("🔍 Pidiendo servicios para la barbería ID: $idBarberia");
    print("🔗 URL: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      // 👇 ¡AQUÍ ESTÁ EL CAMBIO! Aceptamos el 204 como algo bueno
      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print("📦 SERVICIOS RECIBIDOS: $data");
        return data;
      } else if (response.statusCode == 204) {
        print("ℹ️ La barbería $idBarberia no tiene servicios todavía (204).");
        return [];
      } else {
        print("⚠️ Error del servidor. Código: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("🚨 Error cargando servicios de la barbería: $e");
      return [];
    }
  }

  // POST: Crear nuevo servicio en la barbería del trabajador.
  // `duracionMinutos` es OBLIGATORIO: el motor de citas lo usa para detectar solapamientos.
  // Confirmado por Iván el 2026-05-05.
  Future<void> crearServicio(int idBarberia, String nombre, double precio, int duracionMinutos) async {
    final url = "${ApiConfig.baseUrl}/api/servicios/barberia/$idBarberia";
    final headers = await _getHeaders();

    final bodyCodificado = jsonEncode({
      "nombreServicio": nombre,
      "precioServicio": precio,
      "duracionMinutos": duracionMinutos,
    });
    print("🔍 POST crear servicio en: $url");
    print("📦 Datos enviados: $bodyCodificado");

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: bodyCodificado,
    ).timeout(const Duration(seconds: 10));

    print("📩 Respuesta: ${response.statusCode}");
    print("📄 Body: ${response.body}");
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
  // 💰 5. FACTURACIÓN E INGRESOS (ADMIN)
  // ==========================================
  Future<Map<String, dynamic>> getResumenFacturacion() async {
    final url = "${ApiConfig.baseUrl}/api/admin/facturacion/resumen"; // ← /api/ añadido
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
  // ✂ 6. ACCIONES DEL BARBERO
  // ==========================================
  Future<bool> finalizarCita(int idCita) async {
    final url = "${ApiConfig.baseUrl}/citas/$idCita/finalizar";
    try {
      final headers = await _getHeaders();
      final response = await http.put(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      _verificarExpiracion(response);

      // 🛡️ ESCUDO ANTI-ERRORES 400
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
  Future<bool> solicitarRecuperacion(String email) async {

    //  AQUÍ ESTÁ EL CAMBIO: La nueva ruta oficial de Iván
    final url = "${ApiConfig.baseUrl}/api/usuarios/solicitar-recuperacion";

    final Map<String, dynamic> bodyAEnviar = {
      "correoElectronico": email,
    };

    print("🔍 --- INICIO PETICIÓN RECUPERACIÓN --- 🔍");
    print("🔗 URL EXACTA: $url");
    print("📝 BODY EXACTO: ${jsonEncode(bodyAEnviar)}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyAEnviar),
      );

      print("📥 --- RESPUESTA SERVIDOR --- 📥");
      print("🔥 STATUS: ${response.statusCode}");
      print("🔥 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error del servidor (${response.statusCode})");
      }
    } catch (e) {
      print("🚨 ERROR EN RECUPERACIÓN: $e");
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> confirmarRecuperacion(String codigo, String nuevaContrasena) async {
    final url = "${ApiConfig.baseUrl}/api/usuarios/confirmar-recuperacion";
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
    try {
      // 1. Sacamos el correo de la caja fuerte
      final prefs = await SharedPreferences.getInstance();
      final String email = prefs.getString('email_usuario') ?? '';

      if (email.isEmpty) throw Exception("No hay correo guardado en sesión");

      // 2. Montamos la URL exacta que pidió Iván
      final url = "${ApiConfig.baseUrl}/api/usuarios/perfil/$email";

      final headers = await _getHeaders();
      print("🔍 --- PEDIENDO PERFIL --- 🔗 URL: $url");

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));
      _verificarExpiracion(response);

      print("📥 STATUS PERFIL: ${response.statusCode}");
      print("📄 BODY PERFIL: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw Exception("Error del servidor (${response.statusCode})");

    } catch (e) {
      print("🚨 ERROR EN PERFIL: $e");
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

    // 1️⃣ EL ARREGLO DE LA URL: Añadimos el "/api" que faltaba
    final url = Uri.parse('${ApiConfig.baseUrl}/api/usuarios/eliminar/$idCliente');

    try {
      // 2️⃣ LA LLAVE MAESTRA: Recuperamos el token JWT que guardamos al hacer Login
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';

      print("🗑️ --- INICIO BORRADO DE CUENTA --- 🗑️");
      print("🔗 URL: $url");
      print("🔑 TOKEN ENVIADO: Bearer $token");

      final response = await http.delete(
        url,
        // 3⃣ LA CABECERA: Le pasamos el token al "guardia de seguridad" de Iván
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(" --- RESPUESTA SERVIDOR --- 📥");
      print(" STATUS: ${response.statusCode}");
      print(" BODY: ${response.body}");

      // Iván dice que devuelve 200 OK si todo va bien
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

      print("🔍 Pidiendo datos de barbería a: $url");
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null; // Por si Iván devuelve un 200 pero vacío
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 404) {
        // Si devuelve 404 significa que el barbero aún no ha creado su local
        return null;
      }
      return null;
    } catch (e) {
      print("🚨 Error obteniendo barbería: $e");
      return null;
    }
  }

  // --- ACTUALIZAR O CREAR MI BARBERÍA (PUT) ---
  Future<bool> actualizarMiBarberia(int idUsuarioBarbero, Map<String, dynamic> datos) async {
    try {
      final url = "${ApiConfig.baseUrl}/api/barberias/mi-barberia/$idUsuarioBarbero";
      final headers = await _getHeaders();

      print("📤 Enviando datos de barbería a: $url");
      final response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(datos)
      ).timeout(const Duration(seconds: 10));

      print("📥 Respuesta del servidor: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("🚨 Error actualizando barbería: $e");
      return false;
    }
  }
  // ==========================================
  // 🏪 OBTENER TODAS LAS BARBERÍAS (VERSIÓN DETECTIVE)
  // ==========================================
  Future<List<dynamic>> getTodasLasBarberias() async {
    final url = "${ApiConfig.baseUrl}/api/barberias";

    print("🚀 1. Iniciando petición a Barberías...");
    print("🔗 2. URL de destino: $url");

    try {
      print("⏳ 3. Preparando Headers (buscando token en memoria)...");
      final headers = await _getHeaders();
      print("✅ 4. Headers listos. Disparando GET...");

      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      print("📥 5. ¡Respuesta del servidor recibida!");
      print("🔥 STATUS CODE: ${response.statusCode}");
      print("📄 BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print("⚠️ El servidor devolvió 200 pero la lista está VACÍA.");
          return [];
        }
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      print("🚨 6. ERROR CATASTRÓFICO en getTodasLasBarberias: $e");
      return [];
    }
  }
  // ==========================================
  // 🏪 OBTENER BARBERÍA ASIGNADA AL TRABAJADOR
  // ==========================================
  Future<Map<String, dynamic>?> getBarberiaAsignada(String correoBarbero) async {
    final url = "${ApiConfig.baseUrl}/api/barberias/asignada/$correoBarbero";
    print("🔍 Buscando barbería asignada para el correo: $correoBarbero");
    print("🔗 URL: $url");

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print("📦 DATOS RECIBIDOS: $data");
        return data;
      } else {
        print("⚠️ Error del servidor. Código: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("🚨 Error de conexión: $e");
      return null;
    }
  }
}