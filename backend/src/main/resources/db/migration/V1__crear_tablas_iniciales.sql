CREATE TABLE tabla_usuarios (
                                id_usuario BIGSERIAL PRIMARY KEY,
                                correo_electronico VARCHAR(100) NOT NULL UNIQUE,
                                contrasena_usuario VARCHAR(255) NOT NULL,
                                rol_usuario VARCHAR(20) NOT NULL CHECK (rol_usuario IN ('CLIENTE', 'BARBERO', 'ADMIN'))
);

CREATE TABLE tabla_barberias (
                                 id_barberia BIGSERIAL PRIMARY KEY,
                                 nombre_barberia VARCHAR(100) NOT NULL,
                                 direccion_fisica VARCHAR(255) NOT NULL
);

CREATE TABLE tabla_barberos (
                                id_perfil_barbero BIGSERIAL PRIMARY KEY,
                                identificador_usuario BIGINT NOT NULL,
                                identificador_barberia BIGINT NOT NULL,
                                especialidad_corte VARCHAR(100),
                                FOREIGN KEY (identificador_usuario) REFERENCES tabla_usuarios(id_usuario),
                                FOREIGN KEY (identificador_barberia) REFERENCES tabla_barberias(id_barberia)
);

CREATE TABLE tabla_servicios (
                                 id_servicio BIGSERIAL PRIMARY KEY,
                                 nombre_servicio VARCHAR(100) NOT NULL,
                                 precio_servicio DECIMAL(10,2) NOT NULL
);

CREATE TABLE tabla_citas (
                             id_cita BIGSERIAL PRIMARY KEY,
                             identificador_cliente BIGINT NOT NULL,
                             identificador_barbero BIGINT NOT NULL,
                             identificador_servicio BIGINT NOT NULL,
                             fecha_hora_cita TIMESTAMP NOT NULL,
                             estado_cita VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado_cita IN ('PENDIENTE', 'CONFIRMADA', 'COMPLETADA', 'CANCELADA')),
                             FOREIGN KEY (identificador_cliente) REFERENCES tabla_usuarios(id_usuario),
                             FOREIGN KEY (identificador_barbero) REFERENCES tabla_barberos(id_perfil_barbero),
                             FOREIGN KEY (identificador_servicio) REFERENCES tabla_servicios(id_servicio)
);