CREATE TABLE tabla_usuarios (
id_usuario BIGINT AUTO_INCREMENT PRIMARY KEY,
correo_electronico VARCHAR(100) NOT NULL UNIQUE,
contrasena_usuario VARCHAR(255) NOT NULL,
rol_usuario ENUM('CLIENTE', 'BARBERO', 'ADMIN') NOT NULL
);
CREATE TABLE tabla_barberias (
id_barberia BIGINT AUTO_INCREMENT PRIMARY KEY,
nombre_barberia VARCHAR(100) NOT NULL,
direccion_fisica VARCHAR(255) NOT NULL
);
CREATE TABLE tabla_barberos (
id_perfil_barbero BIGINT AUTO_INCREMENT PRIMARY KEY,
identificador_usuario BIGINT NOT NULL,
identificador_barberia BIGINT NOT NULL,
especialidad_corte VARCHAR(100),
FOREIGN KEY (identificador_usuario) REFERENCES tabla_usuarios(id_usuario),
FOREIGN KEY (identificador_barberia) REFERENCES tabla_barberias(id_barberia)
);
CREATE TABLE tabla_servicios (
id_servicio BIGINT AUTO_INCREMENT PRIMARY KEY,
nombre_servicio VARCHAR(100) NOT NULL,
precio_servicio DECIMAL(10,2) NOT NULL
);
CREATE TABLE tabla_citas (
id_cita BIGINT AUTO_INCREMENT PRIMARY KEY,
identificador_cliente BIGINT NOT NULL,
identificador_barbero BIGINT NOT NULL,
identificador_servicio BIGINT NOT NULL,
fecha_hora_cita DATETIME NOT NULL,
estado_cita ENUM('PENDIENTE', 'CONFIRMADA', 'COMPLETADA', 'CANCELADA') DEFAULT 'PENDIENTE',
FOREIGN KEY (identificador_cliente) REFERENCES tabla_usuarios(id_usuario),
FOREIGN KEY (identificador_barbero) REFERENCES tabla_barberos(id_perfil_barbero),
FOREIGN KEY (identificador_servicio) REFERENCES tabla_servicios(id_servicio)
);