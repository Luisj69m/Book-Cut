class ApiConfig {
  // ⚠️ EL MARTES EN CLASE, SI CAMBIA EL ROUTER, SOLO TIENES QUE CAMBIAR ESTA LÍNEA ⚠️
  static const String baseUrl = "https://interracial-tamara-archaeologically.ngrok-free.dev/api";

  // Endpoints centralizados
  static const String login = "$baseUrl/usuarios/login";
  static const String barberos = "$baseUrl/barberos/todos";
  static const String servicios = "$baseUrl/servicios";
  static const String reservarCita = "$baseUrl/citas/reservar";
  static const String registrar = "$baseUrl/usuarios/registrar";

  // Como estos llevan un ID dinámico al final, los hacemos como funciones cortitas
  static String misCitas(int idUsuario) => "$baseUrl/citas/historial/$idUsuario";
  static String cancelarCita(int idCita) => "$baseUrl/citas/cancelar/$idCita";
}