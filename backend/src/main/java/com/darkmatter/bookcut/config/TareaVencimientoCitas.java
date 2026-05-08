import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Component
public class TareaVencimientoCitas {

    @Autowired
    private CitaRepository citaRepository;

    @Autowired
    private EmailService emailService;

    private final DateTimeFormatter formateadorFecha = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");

    @Scheduled(fixedRate = 300000)
    @Transactional
    public void vencerCitasPendientes() {
        LocalDateTime momentoActual = LocalDateTime.now();
        List<Cita> citasAVencer = citaRepository.findByEstadoCitaAndFechaHoraCitaBefore(EstadoCita.PENDIENTE, momentoActual);

        if (citasAVencer.isEmpty()) {
            return;
        }

        for (Cita citaPendiente : citasAVencer) {
            citaPendiente.setEstadoCita(EstadoCita.VENCIDA);
            citaRepository.save(citaPendiente);

            try {
                String fechaFormateada = citaPendiente.getFechaHoraCita().format(formateadorFecha);
                String correoCliente = citaPendiente.getClienteReserva().getCorreoElectronico();
                String asunto = "Cita Vencida - Book&Cut";
                String mensaje = "Hola, tu cita programada para el " + fechaFormateada + " no fue confirmada por el barbero a tiempo y ha quedado vencida. Puedes solicitar una nueva cita cuando quieras.";
                emailService.enviarCorreo(correoCliente, asunto, mensaje);
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
        List<Cita> citasAutoCompletar = citaRepository.findByEstadoCitaAndFechaHoraCitaBefore(EstadoCita.ACEPTADA, limiteAutoCompletado);

        if (citasAutoCompletar.isEmpty()) {
            return;
        }

        for (Cita citaAceptada : citasAutoCompletar) {
            citaAceptada.setEstadoCita(EstadoCita.COMPLETADA);
            citaRepository.save(citaAceptada);

            try {
                String fechaFormateada = citaAceptada.getFechaHoraCita().format(formateadorFecha);
                String correoCliente = citaAceptada.getClienteReserva().getCorreoElectronico();
                String asunto = "Cita Completada Automáticamente - Book&Cut";
                String mensaje = "Hola, tu cita del " + fechaFormateada + " ha sido marcada como completada automáticamente al no haber sido finalizada por el barbero dentro del plazo establecido. Gracias por confiar en nosotros.";
                emailService.enviarCorreo(correoCliente, asunto, mensaje);
            } catch (Exception excepcionCorreo) {
                System.err.println("Error al enviar correo de auto-completado: " + excepcionCorreo.getMessage());
            }
        }

        System.out.println("TareaVencimientoCitas: " + citasAutoCompletar.size() + " citas aceptadas auto-completadas.");
    }
}