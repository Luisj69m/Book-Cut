# 💈 BookCut - Gestión Inteligente de Barberías

**BookCut** es una solución integral diseñada para digitalizar la experiencia de reserva en barberías, conectando a clientes y profesionales en tiempo real a través de una arquitectura robusta y escalable.

## 🚀 Estado del MVP (Funcionalidades Clave)
Actualmente, el proyecto ha completado su ciclo principal de valor:
- **Reserva en Tiempo Real:** Los clientes pueden solicitar citas enviando datos precisos al backend.
- **Gestión de Estados (Core):** Implementación de una lógica de estados (`PENDIENTE`, `ACEPTADA`, `RECHAZADA`, `CANCELADA`) mediante un sistema de actualización directa en base de datos.
- **Sincronización Multi-plataforma:** Comunicación fluida entre el frontend (Flutter) y el servidor (Spring Boot) mediante protocolos REST.

## 🛠️ Stack Tecnológico
- **Frontend:** Flutter (Dart) - Interfaz de usuario intuitiva y reactiva.
- **Backend:** Spring Boot (Java 17+) - API REST con persistencia de datos.
- **Base de Datos:** MySQL - Modelo relacional optimizado para integridad de citas.
- **ORM:** Hibernate / JPA - Mapeo de entidades con consultas nativas para actualizaciones críticas.
- **Túnel de Red:** Ngrok - Exposición segura del servidor local para pruebas en dispositivos físicos.

## 📦 Estructura del Proyecto
- `/backend`: Lógica de servidor, controladores de citas y repositorios.
- `/frontend`: Aplicación móvil desarrollada en Flutter.
- `/docs`: Documentación del diseño, esquemas SQL y manuales de usuario.

## 🔧 Configuración y Despliegue
### Backend
1. Importar el proyecto en IntelliJ/Eclipse.
2. Configurar el archivo `application.properties` con tus credenciales de MySQL.
3. Ejecutar la clase principal.
4. Levantar Ngrok: `ngrok http 8080`.

### Frontend
1. Cambiar la `baseUrl` en el servicio de Flutter por la URL generada por Ngrok.
2. Ejecutar `flutter run`.

## 👥 Equipo
- Iván, Luis y Daniel.