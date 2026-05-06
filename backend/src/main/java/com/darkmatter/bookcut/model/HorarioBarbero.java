package com.darkmatter.bookcut.model;
import jakarta.persistence.*;
import java.time.LocalTime;
@Entity
@Table(name = "tabla_horarios_barberos")
public class HorarioBarbero {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idHorario;
    @ManyToOne
    @JoinColumn(name = "id_perfil_barbero", nullable = false)
    private Barbero barbero;
    @Column(name = "dia_semana") // Ejemplo: "LUNES", "MARTES"
    private String diaSemana;
    @Column(name = "hora_inicio")
    private LocalTime horaInicio;
    @Column(name = "hora_fin")
    private LocalTime horaFin;
    // Getters y Setters necesarios para que Spring funcione
    public Long getIdHorario() { return idHorario; }
    public void setIdHorario(Long idHorario) { this.idHorario = idHorario; }
    public Barbero getBarbero() { return barbero; }
    public void setBarbero(Barbero barbero) { this.barbero = barbero; }
    public String getDiaSemana() { return diaSemana; }
    public void setDiaSemana(String diaSemana) { this.diaSemana = diaSemana; }
    public LocalTime getHoraInicio() { return horaInicio; }
    public void setHoraInicio(LocalTime horaInicio) { this.horaInicio = horaInicio; }
    public LocalTime getHoraFin() { return horaFin; }
    public void setHoraFin(LocalTime horaFin) { this.horaFin = horaFin; }
}