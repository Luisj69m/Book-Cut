package com.darkmatter.bookcut.model;

/**
 * Enumeración que define el ciclo de vida estricto de una cita en el sistema.
 * Es vital para el cálculo de facturación (COMPLETADA) y para la gestión
 * automatizada del servidor (vencimiento y autocompletado).
 */
public enum EstadoCita {
    PENDIENTE,
    ACEPTADA,
    RECHAZADA,
    COMPLETADA,
    CANCELADA,
    VENCIDA
}