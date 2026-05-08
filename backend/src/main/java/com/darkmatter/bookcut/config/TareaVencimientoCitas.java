package com.darkmatter.bookcut.config;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.service.EmailService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Tareas programadas para gestionar el ciclo de vida automático de las citas.
 * Evalúa estados PENDIENTE y ACEPTADA para evitar inconsistencias en el calendario y facturación.
 */
@Component
public class TareaVencimientoCitas {

    private final CitaRepository repositorioCitas;
    private final EmailService servicioCorreo;
    private final DateTimeFormatter formateadorFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");

    public TareaVencimientoCitas(CitaRepository repositorioCitas, EmailService servicioCorreo) {
        this.repositorioCitas = repositorioCitas;
        this.servicioCorreo = servicioCorreo;
    }

    @Scheduled(fixedRate = 300000)
    @Transactional
    public void vencerCitasPendientes() {
        LocalDateTime momentoActual = LocalDateTime.now();
        List<Cita> citasAVencer = repositorioCitas.findByEstadoCitaAndFechaHoraCitaBefore(EstadoCita.PENDIENTE, momentoActual);

        if (citasAVencer.isEmpty()) {
            return;
        }

        for (Cita citaPendiente : citasAVencer) {
            citaPendiente.setEstadoCita(EstadoCita.VENCIDA);
            repositorioCitas.save(citaPendiente);

            try {
                String fechaFormateada = citaPendiente.getFechaHoraCita().format(formateadorFecha);
                String correoCliente = citaPendiente.getClienteReserva().getCorreoElectronico();
                String asunto = "Cita Vencida - BookCut";
                String mensaje = "Hola, tu cita programada para el " + fechaFormateada + " no fue confirmada por el barbero a tiempo y ha quedado vencida. Puedes solicitar una nueva cita cuando quieras.";
                servicioCorreo.enviarCorreo(correoCliente, asunto, mensaje);
            } catch (Exception excepcionCorreo) {
                System.err.println("Error al enviar correo de cita vencida: " + excepcionCorreo.getMessage());
            }
        }

        System.out.println("TareaVencimientoCitas: " + citasAVencer.size() + " citas pendientes vencidas.");
    }

    @Scheduled(fixedRate = 1800000)
    @Transactional
    public void autoCompletarCitasAceptadas() {
        LocalDateTime limiteAutoCompletado = LocalDateTime.now().minusHours(24);
        List<Cita> citasAutoCompletar = repositorioCitas.findByEstadoCitaAndFechaHoraCitaBefore(EstadoCita.ACEPTADA, limiteAutoCompletado);

        if (citasAutoCompletar.isEmpty()) {
            return;
        }

        for (Cita citaAceptada : citasAutoCompletar) {
            citaAceptada.setEstadoCita(EstadoCita.COMPLETADA);
            repositorioCitas.save(citaAceptada);

            try {
                String fechaFormateada = citaAceptada.getFechaHoraCita().format(formateadorFecha);
                String correoCliente = citaAceptada.getClienteReserva().getCorreoElectronico();
                String asunto = "Cita Completada Automáticamente - BookCut";
                String mensaje = "Hola, tu cita del " + fechaFormateada + " ha sido marcada como completada automáticamente. Gracias por confiar en nosotros.";
                servicioCorreo.enviarCorreo(correoCliente, asunto, mensaje);
            } catch (Exception excepcionCorreo) {
                System.err.println("Error al enviar correo de auto-completado: " + excepcionCorreo.getMessage());
            }
        }

        System.out.println("TareaVencimientoCitas: " + citasAutoCompletar.size() + " citas aceptadas auto-completadas.");
    }
}