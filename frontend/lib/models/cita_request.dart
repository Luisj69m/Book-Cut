class CitaRequest {
  final int idCliente;
  final int idBarbero;
  final int idServicio;
  final DateTime fechaHora;

  CitaRequest({
    required this.idCliente,
    required this.idBarbero,
    required this.idServicio,
    required this.fechaHora,
  });

  // Este método transforma los datos de Flutter al JSON exacto que pide Spring Boot
  Map<String, dynamic> toJson() {
    return {
      "clienteReserva": {"idUsuario": idCliente},
      "barberoAsignado": {"idPerfilBarbero": idBarbero},
      "servicioContratado": {"idServicio": idServicio},
      "fechaHoraCita": fechaHora.toIso8601String(),
      "estadoCita": "PENDIENTE"
    };
  }
}