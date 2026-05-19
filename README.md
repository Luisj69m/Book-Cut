# 💈 BookCut - Plataforma de Gestión para Barberías

BookCut es una solución integral que digitaliza la gestión completa de barberías, conectando clientes, barberos y administradores en tiempo real a través de una arquitectura moderna, escalable y desplegada en la nube.

---

## 🚀 Características Principales

### Sistema de Reservas Inteligente
- **Reserva en Tiempo Real**: Los clientes solicitan citas que los barberos pueden aceptar o rechazar
- **Gestión de Estados**: Sistema completo de ciclo de vida de citas (`PENDIENTE`, `ACEPTADA`, `RECHAZADA`, `CANCELADA`, `COMPLETADA`, `VENCIDA`)
- **Validación de Disponibilidad**: Detección automática de solapamientos de horarios
- **Recordatorios Automatizados**: Sistema de notificaciones por correo 24h antes de cada cita

### Notificaciones por Email
- **Plantillas HTML Profesionales**: Correos diseñados con gradientes, badges de estado y contenido estructurado
- **7 Tipos de Notificaciones**:
  - Bienvenida al registrarse
  - Solicitud de cita recibida
  - Cita confirmada
  - Cita rechazada
  - Cita cancelada
  - Cita completada
  - Recordatorio 24h antes

### Gestión de Imágenes
- **Fotos de Barberías**: Sistema de galería con carrusel de imágenes
- **Fotos de Perfil**: Cada usuario puede subir y personalizar su avatar
- **Almacenamiento Cloud**: URLs públicas accesibles desde cualquier dispositivo

### Panel de Administración
- **Gestión de Barberías**: Creación, edición y eliminación de locales
- **Registro de Barberos**: Asignación de empleados a barberías específicas
- **Dashboard de Facturación**: Resumen de ingresos filtrable por día, semana, mes o total
- **Visualización de Citas**: Vista global de todas las reservas por barbería

### Roles y Permisos
- **ADMIN**: Control total del sistema, gestión de barberías y barberos
- **BARBERO**: Gestión de sus propias citas, horarios y perfil
- **CLIENTE**: Reserva de citas, historial personal y gestión de perfil

---

## 🛠️ Stack Tecnológico

### Backend
- **Framework**: Spring Boot 3.x (Java 17+)
- **Seguridad**: Spring Security con autenticación JWT
- **ORM**: JPA / Hibernate
- **Base de Datos**: PostgreSQL
- **Migraciones**: Flyway
- **Email**: Brevo REST API
- **Almacenamiento**: Supabase Storage

### Frontend
- **Panel Admin**: React
- **App Móvil**: Flutter

---

## 📦 Arquitectura del Proyecto
bookcut-backend/
├── src/main/java/com/darkmatter/bookcut/
│   ├── controller/          # Endpoints REST
│   ├── model/               # Entidades JPA
│   ├── repository/          # Acceso a datos
│   ├── service/             # Lógica de negocio
│   ├── DTO/                 # Objetos de transferencia
│   ├── security/            # Configuración JWT
│   └── config/              # Configuración Spring
└── src/main/resources/
└── application.properties

---

## 🗄️ Modelo de Datos

### Entidades Principales

**Usuario**
- Datos personales, rol, contraseña encriptada (BCrypt), foto de perfil

**Barberia**
- Información del local, dirección, horarios, descripción, imagen

**Barbero**
- Perfil profesional vinculado a usuario y barbería

**Cita**
- Relación entre cliente, barbero y servicio con gestión de estados

**Servicio**
- Tratamientos ofrecidos con precio y duración

---

## 🔐 Seguridad

### Autenticación JWT
- Token generado al login
- Contraseñas encriptadas con BCrypt

### Políticas de Acceso
- **Rutas Públicas**: Login, registro, listado de barberías
- **Solo ADMIN**: Gestión de sistema y barberos
- **ADMIN o BARBERO**: Facturación y gestión de barberías
- **Autenticado**: Gestión de perfil y citas

---

## 📡 API REST Endpoints

### Autenticación
- `POST /api/usuarios/login` - Iniciar sesión
- `POST /api/usuarios/registrar` - Registro
- Recuperación de contraseña

### Gestión
- Usuarios y perfiles
- Barberías y barberos
- Citas y servicios
- Imágenes (barberías y perfiles)
- Dashboard de facturación

---

## 📧 Sistema de Notificaciones

- Plantillas HTML responsive
- Envío automático según estado de cita
- Recordatorios programados 24h antes
- Branding corporativo

---

## 👥 Equipo

- **Iván Rubio** - Backend (Spring Boot, Arquitectura, Base de Datos, Seguridad)
- **Luis** - Frontend Admin (React, Panel de gestión, Dashboard)
- **Daniel** - Frontend Móvil (Flutter, App de clientes y barberos)

---

## 📄 Licencia

MIT License - Ver archivo `LICENSE` para más detalles.

---

**Proyecto desarrollado como Trabajo de Fin de Grado - 2026**
