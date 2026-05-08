package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/admin/facturacion")
public class FacturacionController {

    @Autowired
    private CitaRepository repositorioDeCitas;

    @GetMapping("/resumen")
    public Map<String, Object> obtenerResumenIngresos(@RequestParam(defaultValue = "siempre") String periodoFiltro) {

        LocalDateTime momentoActual = LocalDateTime.now();
        LocalDateTime fechaInicioFiltro;
        LocalDateTime fechaFinFiltro = momentoActual;

        switch (periodoFiltro.toLowerCase()) {
            case "dia":
                fechaInicioFiltro = momentoActual.with(LocalTime.MIN);
                break;
            case "semana":
                fechaInicioFiltro = momentoActual.with(DayOfWeek.MONDAY).with(LocalTime.MIN);
                break;
            case "mes":
                fechaInicioFiltro = momentoActual.with(TemporalAdjusters.firstDayOfMonth()).with(LocalTime.MIN);
                break;
            default:
                fechaInicioFiltro = LocalDateTime.of(2000, 1, 1, 0, 0);
                break;
        }

        List<Cita> citasCompletadasFiltradas = repositorioDeCitas.findByEstadoCitaAndFechaHoraCitaBetween(
                EstadoCita.COMPLETADA,
                fechaInicioFiltro,
                fechaFinFiltro
        );

        BigDecimal ingresosTotalesAcumulados = citasCompletadasFiltradas.stream()
                .map(cita -> {
                    if (cita.getPrecioFinal() != null) {
                        return cita.getPrecioFinal();
                    }
                    if (cita.getServicioContratado() != null && cita.getServicioContratado().getPrecioServicio() != null) {
                        return cita.getServicioContratado().getPrecioServicio();
                    }
                    return BigDecimal.ZERO;
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> respuestaFacturacion = new HashMap<>();
        respuestaFacturacion.put("totalIngresos", ingresosTotalesAcumulados);
        respuestaFacturacion.put("cantidadCitas", citasCompletadasFiltradas.size());
        respuestaFacturacion.put("citasDetalle", citasCompletadasFiltradas);
        respuestaFacturacion.put("periodoConsultado", periodoFiltro);

        return respuestaFacturacion;
    }
}