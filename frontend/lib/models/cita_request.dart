class CitaRequest {
  // Quitamos idCliente e emailCliente porque el backend ya no los necesita aquí.
  final int idBarberia; // <-- Cambiado el nombre para que coincida
  final int idServicio;
  final DateTime fechaHora;

  CitaRequest({
    required this.idBarberia,
    required this.idServicio,
    required this.fechaHora,
  });

  Map<String, dynamic> toJson() {
    return {
      "idBarberia": idBarberia,
      "idServicio": idServicio,
      "fechaHoraCita": fechaHora.toIso8601String().split('.')[0], // La fecha limpia
    };
  }
}