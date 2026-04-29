package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/admin/facturacion")
public class FacturacionController {

    @Autowired
    private CitaRepository citaRepository;

    @GetMapping("/resumen")
    public Map<String, Object> obtenerResumenIngresos() {
        // 1. Buscamos todas las citas finalizadas
        List<Cita> citasFinalizadas = citaRepository.findByEstadoCita(EstadoCita.COMPLETADA);

        // 2. Calculamos el total sumando el precio de cada servicio
        BigDecimal totalAcumulado = citasFinalizadas.stream()
                .map(cita -> cita.getServicioContratado().getPrecioServicio())
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // 3. Preparamos la respuesta para el panel de ingresos
        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("totalIngresos", totalAcumulado);
        respuesta.put("cantidadCitas", citasFinalizadas.size());
        respuesta.put("citasDetalle", citasFinalizadas);

        return respuesta;
    }
}