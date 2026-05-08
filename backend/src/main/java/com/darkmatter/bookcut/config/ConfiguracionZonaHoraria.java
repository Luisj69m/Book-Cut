package com.darkmatter.bookcut.config;



import jakarta.annotation.PostConstruct;

import org.springframework.context.annotation.Configuration;



import java.util.TimeZone;



@Configuration

public class ConfiguracionZonaHoraria {



    @PostConstruct

    public void inicializarZonaHoraria() {

        TimeZone.setDefault(TimeZone.getTimeZone("Europe/Madrid"));

    }

}