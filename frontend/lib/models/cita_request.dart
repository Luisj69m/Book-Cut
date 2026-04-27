class CitaRequest {
  final int idCliente;
  final String emailCliente; // <-- NUEVO: Para enviar el correo
  final int idBarbero;
  final int idServicio;
  final DateTime fechaHora;

  CitaRequest({
    required this.idCliente,
    required this.emailCliente,
    required this.idBarbero,
    required this.idServicio,
    required this.fechaHora,
  });

  Map<String, dynamic> toJson() {
    return {
      "clienteReserva": {
        "idUsuario": idCliente,
        "correoElectronico": emailCliente
      },
      "barberoAsignado": {"idPerfilBarbero": idBarbero},
      "servicioContratado": {"idServicio": idServicio},
      "fechaHoraCita": fechaHora.toIso8601String().split('.')[0], // La fecha limpia
      "estadoCita": "PENDIENTE"
    };
  }
}