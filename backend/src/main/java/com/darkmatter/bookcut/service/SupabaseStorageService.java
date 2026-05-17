package com.darkmatter.bookcut.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;

@Service
public class SupabaseStorageService {

    @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.key}")
    private String supabaseKey;

    private final RestTemplate restTemplate = new RestTemplate();

    // MÉTODO GENÉRICO PARA SUBIR IMÁGENES
    public String subirImagen(MultipartFile archivo, String bucketName) throws Exception {
        String nombreArchivo = UUID.randomUUID().toString() + "-" + archivo.getOriginalFilename();
        String url = supabaseUrl + "/storage/v1/object/" + bucketName + "/" + nombreArchivo;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.setContentType(MediaType.parseMediaType(archivo.getContentType()));

        HttpEntity<byte[]> requestEntity = new HttpEntity<>(archivo.getBytes(), headers);

        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, requestEntity, String.class);

        if (response.getStatusCode() == HttpStatus.OK) {
            return supabaseUrl + "/storage/v1/object/public/" + bucketName + "/" + nombreArchivo;
        } else {
            throw new RuntimeException("Error al subir imagen: " + response.getBody());
        }
    }

    // SUBIR IMAGEN DE BARBERÍA
    public String subirImagenBarberia(MultipartFile archivo) throws Exception {
        return subirImagen(archivo, "barberias-imagenes");
    }

    // SUBIR FOTO DE PERFIL
    public String subirFotoPerfil(MultipartFile archivo) throws Exception {
        return subirImagen(archivo, "fotos-perfil");
    }

    // LISTAR IMÁGENES DE UN BUCKET
    public List<Map<String, String>> listarImagenes(String bucketName) throws Exception {
        String url = supabaseUrl + "/storage/v1/object/list/" + bucketName;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<String> requestEntity = new HttpEntity<>("{}", headers);

        ResponseEntity<List> response = restTemplate.exchange(url, HttpMethod.POST, requestEntity, List.class);

        List<Map<String, String>> imagenes = new ArrayList<>();
        if (response.getBody() != null) {
            for (Object obj : response.getBody()) {
                Map<String, Object> file = (Map<String, Object>) obj;
                String nombre = (String) file.get("name");

                Map<String, String> imagen = new HashMap<>();
                imagen.put("nombre", nombre);
                imagen.put("url", supabaseUrl + "/storage/v1/object/public/" + bucketName + "/" + nombre);

                imagenes.add(imagen);
            }
        }

        return imagenes;
    }

    // LISTAR IMÁGENES DE BARBERÍAS
    public List<Map<String, String>> listarImagenesBarberias() throws Exception {
        return listarImagenes("barberias-imagenes");
    }

    // LISTAR FOTOS DE PERFIL
    public List<Map<String, String>> listarFotosPerfil() throws Exception {
        return listarImagenes("fotos-perfil");
    }

    // ELIMINAR IMAGEN
    public void eliminarImagen(String nombreArchivo, String bucketName) throws Exception {
        String url = supabaseUrl + "/storage/v1/object/" + bucketName + "/" + nombreArchivo;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + supabaseKey);

        HttpEntity<String> requestEntity = new HttpEntity<>(headers);

        restTemplate.exchange(url, HttpMethod.DELETE, requestEntity, String.class);
    }
}