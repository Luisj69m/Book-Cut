package com.darkmatter.bookcut.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.Map;

@Service
public class CloudinaryService {

    private final Cloudinary configuracionCloudinary;

    public CloudinaryService(
            @Value("${cloudinary.cloud-name}") String nombreNube,
            @Value("${cloudinary.api-key}") String claveApi,
            @Value("${cloudinary.api-secret}") String secretoApi) {

        this.configuracionCloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", nombreNube,
                "api_key", claveApi,
                "api_secret", secretoApi));
    }

    public String subirImagen(MultipartFile archivoImagen) throws IOException {
        Map resultadoSubida = configuracionCloudinary.uploader().upload(archivoImagen.getBytes(), ObjectUtils.emptyMap());
        return resultadoSubida.get("secure_url").toString();
    }
}
