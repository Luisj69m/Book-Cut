# Usamos una imagen de Java ligera
FROM eclipse-temurin:21-jdk-jammy

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos de Maven para instalar dependencias primero (cache)
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

# Copiamos el código fuente y compilamos el proyecto
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Exponemos el puerto 8080
EXPOSE 8080

# Comando para ejecutar la aplicación
# Asegúrate de que el nombre del .jar sea el correcto
CMD ["java", "-jar", "target/bookcut-0.0.1-SNAPSHOT.jar"]