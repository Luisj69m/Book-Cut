# Bookcut - Sistema de Reserva para Barberias

Aplicacion movil y panel de gestion para la reserva de citas en locales de barberia.

## Vision General del Proyecto

Este proyecto tiene como objetivo digitalizar el proceso de reserva de citas, permitiendo a los clientes seleccionar servicios, horarios y barberos. Al mismo tiempo, dota a los administradores y profesionales de herramientas para gestionar la disponibilidad, los horarios y las sedes.

## Tecnologias Utilizadas

| Area | Tecnologia |
| :--- | :--- |
| Frontend | Flutter |
| Backend | Java con Spring Boot |
| Base de Datos | MySQL |
| Infraestructura | Docker y Flyway |

## Guia de Instalacion y Ejecucion Local

Sigue estos pasos para desplegar el entorno de desarrollo en tu maquina local:

1. Clonar el Repositorio:
   git clone https://github.com/Luisj69m/Book-Cut.git
   cd Book-Cut

2. Levantar la Base de Datos (Docker):
   Asegurate de tener Docker Desktop abierto y ejecuta el siguiente comando en la raiz del proyecto:
   docker-compose up -d

3. Ejecutar el Backend (Spring Boot):
   Abre el proyecto en tu editor y ejecuta la clase principal, o utiliza Maven desde la terminal en la carpeta del backend:
   ./mvnw spring-boot:run

La API REST estara disponible y escuchando peticiones en http://localhost:8080

## Colaboradores

| Nombre | Rol en el Proyecto | GitHub |
| :--- | :--- | :--- |
| Daniel Monino Garcia | Desarrollador Frontend | daniimg8 |
| Luis Jose Marcano Fuentes | Desarrollador Backend | Luisj69m |
| Ivan Rubio Murillo | Desarrollador Backend / DBA | ivaanrubio47 |