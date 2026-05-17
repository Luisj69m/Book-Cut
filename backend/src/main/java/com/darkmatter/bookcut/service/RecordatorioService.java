package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class RecordatorioService {

    private final CitaRepository citaRepository;
    private final BrevoEmailService emailService;

    public RecordatorioService(CitaRepository citaRepository, BrevoEmailService emailService) {
        this.citaRepository = citaRepository;
        this.emailService = emailService;
    }

    // Se ejecuta cada hora (3600000 ms = 1 hora)
    @Scheduled(fixedRate = 3600000)
    public void enviarRecordatorios24h() {
        System.out.println("🔔 Ejecutando tarea de recordatorios...");

        LocalDateTime ahora = LocalDateTime.now();
        LocalDateTime dentro24h = ahora.plusHours(24);
        LocalDateTime dentro25h = ahora.plusHours(25);

        // Buscar citas ACEPTADAS entre 24 y 25 horas desde ahora
        List<Cita> citasProximas = citaRepository.findByEstadoCitaAndFechaHoraCitaBetween(
                EstadoCita.ACEPTADA,
                dentro24h,
                dentro25h
        );

        System.out.println("📊 Citas encontradas para recordatorio: " + citasProximas.size());

        DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");

        for (Cita cita : citasProximas) {
            try {
                String nombreCliente = cita.getClienteReserva().getNombre();
                String correoCliente = cita.getClienteReserva().getCorreoElectronico();
                String nombreBarbero = cita.getBarberoAsignado().getUsuarioAsignado().getNombre();
                String nombreBarberia = cita.getBarberoAsignado().getBarberiaAsignada().getNombre();
                String direccion = cita.getBarberoAsignado().getBarberiaAsignada().getDireccionCompleta();
                String fechaFormateada = cita.getFechaHoraCita().format(formateador);
                String nombreServicio = cita.getServicioContratado().getNombreServicio();

                emailService.enviarCorreoRecordatorio24h(
                        correoCliente,
                        nombreCliente,
                        nombreBarbero,
                        nombreBarberia,
                        fechaFormateada,
                        nombreServicio,
                        direccion
                );

                System.out.println("✅ Recordatorio enviado a: " + correoCliente + " (Cita ID: " + cita.getIdCita() + ")");

            } catch (Exception e) {
                System.err.println("❌ Error enviando recordatorio para cita ID " + cita.getIdCita() + ": " + e.getMessage());
            }
        }

        System.out.println("🏁 Tarea de recordatorios completada.\n");
    }
}
