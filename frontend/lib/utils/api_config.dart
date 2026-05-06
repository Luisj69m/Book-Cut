class ApiConfig {

  static const String baseUrl = "https://book-cut.onrender.com";

  // Endpoints centralizados
  static const String login = "$baseUrl/usuarios/login";
  static const String barberos = "$baseUrl/barberos/todos";
  static const String servicios = "$baseUrl/servicios";
  static const String reservarCita = "$baseUrl/citas/reservar";
  static const String registrar = "$baseUrl/usuarios/registrar";

  // Como estos llevan un ID dinámico al final, los hacemos como funciones cortitas
  static String misCitas(int idUsuario) => "$baseUrl/citas/historial/$idUsuario";
  static String cancelarCita(int idCita) => "$baseUrl/citas/cancelar/$idCita";


  // NUEVA RUTA
  static String cambiarEstadoCita(int idCita) => "$baseUrl/citas/$idCita/estado";
}