package com.darkmatter.bookcut.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender enviadorDeCorreos;

    public void enviarCorreoConfirmacion(String correoDestino, String fechaCita) {
        try {
            SimpleMailMessage mensajeConfirmacion = new SimpleMailMessage();
            mensajeConfirmacion.setTo(correoDestino);
            mensajeConfirmacion.setSubject("Confirmación de Reserva - Book&Cut");

            String contenidoMensaje = "Estimado cliente,\n\n" +
                    "Tu reserva en Book&Cut ha sido confirmada con éxito.\n" +
                    "Fecha y hora: " + fechaCita + "\n\n" +
                    "Si necesitas cancelar o modificar tu cita, por favor contáctanos con antelación.\n\n" +
                    "¡Gracias por confiar en nosotros!";

            mensajeConfirmacion.setText(contenidoMensaje);
            enviadorDeCorreos.send(mensajeConfirmacion);
        } catch (Exception errorEnvio) {
            // Se captura el error para no interrumpir el flujo principal de la aplicación
            // Aquí podrías añadir un sistema de logs en el futuro
        }
    }
}

