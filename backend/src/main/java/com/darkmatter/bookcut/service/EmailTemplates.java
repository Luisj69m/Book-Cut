package com.darkmatter.bookcut.service;

public class EmailTemplates {

    private static final String HEADER = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background-color: #f4f4f4;
                }
                .container {
                    max-width: 600px;
                    margin: 20px auto;
                    background-color: #ffffff;
                    border-radius: 10px;
                    overflow: hidden;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }
                .header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    padding: 30px;
                    text-align: center;
                    color: white;
                }
                .header h1 {
                    margin: 0;
                    font-size: 28px;
                    font-weight: 600;
                }
                .content {
                    padding: 40px 30px;
                    color: #333333;
                    line-height: 1.6;
                }
                .content h2 {
                    color: #667eea;
                    font-size: 22px;
                    margin-top: 0;
                }
                .info-box {
                    background-color: #f8f9fa;
                    border-left: 4px solid #667eea;
                    padding: 15px 20px;
                    margin: 20px 0;
                    border-radius: 5px;
                }
                .info-box p {
                    margin: 8px 0;
                }
                .info-box strong {
                    color: #667eea;
                }
                .button {
                    display: inline-block;
                    padding: 12px 30px;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    text-decoration: none;
                    border-radius: 25px;
                    margin: 20px 0;
                    font-weight: 600;
                }
                .footer {
                    background-color: #f8f9fa;
                    padding: 20px;
                    text-align: center;
                    color: #666666;
                    font-size: 14px;
                }
                .badge {
                    display: inline-block;
                    padding: 6px 15px;
                    border-radius: 20px;
                    font-size: 14px;
                    font-weight: 600;
                    margin: 10px 0;
                }
                .badge-success {
                    background-color: #d4edda;
                    color: #155724;
                }
                .badge-warning {
                    background-color: #fff3cd;
                    color: #856404;
                }
                .badge-danger {
                    background-color: #f8d7da;
                    color: #721c24;
                }
                .badge-info {
                    background-color: #d1ecf1;
                    color: #0c5460;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>✂️ BookCut</h1>
                </div>
                <div class="content">
        """;

    private static final String FOOTER = """
                </div>
                <div class="footer">
                    <p><strong>BookCut</strong> - Tu barbería digital</p>
                    <p>Este es un correo automático, por favor no respondas a este mensaje.</p>
                    <p style="color: #999; font-size: 12px; margin-top: 15px;">
                        © 2026 BookCut. Todos los derechos reservados.
                    </p>
                </div>
            </div>
        </body>
        </html>
        """;

    public static String plantillaRecuperacion(String nombreUsuario, String codigoRecuperacion) {
        return HEADER + String.format("""
            <h2>Recuperación de Contraseña</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Has solicitado restablecer tu contraseña en BookCut.</p>
            
            <div class="info-box">
                <p><strong>Tu código de recuperación es:</strong></p>
                <h1 style="text-align: center; color: #667eea; font-size: 36px; letter-spacing: 5px; margin: 15px 0;">%s</h1>
            </div>
            
            <p>Introduce este código en la aplicación para crear una nueva contraseña.</p>
            <p style="color: #999; font-size: 14px;">⏱️ Este código expirará en 15 minutos.</p>
            
            <p style="margin-top: 30px; color: #666;">Si no solicitaste este cambio, ignora este correo.</p>
            """, nombreUsuario, codigoRecuperacion) + FOOTER;
    }

    public static String plantillaCitaCreada(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                             String fechaHora, String servicio, String precio) {
        return HEADER + String.format("""
            <h2>Solicitud de Cita Recibida</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Hemos recibido tu solicitud de cita. Estamos procesando tu reserva.</p>
            
            <div class="info-box">
                <p><strong>📍 Barbería:</strong> %s</p>
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha y hora:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
                <p><strong>💰 Precio:</strong> %s €</p>
            </div>
            
            <span class="badge badge-warning">⏳ PENDIENTE DE CONFIRMACIÓN</span>
            
            <p style="margin-top: 20px;">Recibirás un correo cuando tu cita sea confirmada.</p>
            """, nombreCliente, nombreBarberia, nombreBarbero, fechaHora, servicio, precio) + FOOTER;
    }

    public static String plantillaCitaAceptada(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                               String fechaHora, String servicio, String precio) {
        return HEADER + String.format("""
            <h2>¡Cita Confirmada! ✅</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Tu cita ha sido <strong>confirmada</strong>. ¡Te esperamos!</p>
            
            <div class="info-box">
                <p><strong>📍 Barbería:</strong> %s</p>
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha y hora:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
                <p><strong>💰 Precio:</strong> %s €</p>
            </div>
            
            <span class="badge badge-success">✅ CONFIRMADA</span>
            
            <p style="margin-top: 20px; padding: 15px; background-color: #e7f3ff; border-radius: 5px;">
                💡 <strong>Consejo:</strong> Te recomendamos llegar 5 minutos antes de tu cita.
            </p>
            """, nombreCliente, nombreBarberia, nombreBarbero, fechaHora, servicio, precio) + FOOTER;
    }

    public static String plantillaCitaRechazada(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                                String fechaHora, String servicio) {
        return HEADER + String.format("""
            <h2>Cita No Disponible</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Lamentamos informarte que tu solicitud de cita no ha podido ser confirmada.</p>
            
            <div class="info-box">
                <p><strong>📍 Barbería:</strong> %s</p>
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha y hora solicitada:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
            </div>
            
            <span class="badge badge-danger">❌ NO DISPONIBLE</span>
            
            <p style="margin-top: 20px;">Por favor, selecciona otro horario disponible desde la aplicación.</p>
            """, nombreCliente, nombreBarberia, nombreBarbero, fechaHora, servicio) + FOOTER;
    }

    public static String plantillaCitaCancelada(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                                String fechaHora, String servicio) {
        return HEADER + String.format("""
            <h2>Cita Cancelada</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Tu cita ha sido <strong>cancelada</strong>.</p>
            
            <div class="info-box">
                <p><strong>📍 Barbería:</strong> %s</p>
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha y hora:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
            </div>
            
            <span class="badge badge-danger">❌ CANCELADA</span>
            
            <p style="margin-top: 20px;">Esperamos verte pronto. Puedes reservar una nueva cita cuando quieras.</p>
            """, nombreCliente, nombreBarberia, nombreBarbero, fechaHora, servicio) + FOOTER;
    }

    public static String plantillaCitaCompletada(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                                 String fechaHora, String servicio, String precio) {
        return HEADER + String.format("""
            <h2>¡Gracias por tu visita! 🎉</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Esperamos que hayas disfrutado de tu experiencia en <strong>%s</strong>.</p>
            
            <div class="info-box">
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
                <p><strong>💰 Total pagado:</strong> %s €</p>
            </div>
            
            <span class="badge badge-success">✅ COMPLETADA</span>
            
            <p style="margin-top: 20px;">¡Esperamos verte de nuevo pronto!</p>
            <p>¿Quedaste satisfecho con el servicio? Tu opinión nos importa.</p>
            """, nombreCliente, nombreBarberia, nombreBarbero, fechaHora, servicio, precio) + FOOTER;
    }

    public static String plantillaRecordatorio24h(String nombreCliente, String nombreBarbero, String nombreBarberia,
                                                  String fechaHora, String servicio, String direccion) {
        return HEADER + String.format("""
            <h2>⏰ Recordatorio de Cita</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Este es un recordatorio de que tienes una cita <strong>mañana</strong>.</p>
            
            <div class="info-box">
                <p><strong>📍 Barbería:</strong> %s</p>
                <p><strong>📍 Dirección:</strong> %s</p>
                <p><strong>💈 Barbero:</strong> %s</p>
                <p><strong>📅 Fecha y hora:</strong> %s</p>
                <p><strong>✂️ Servicio:</strong> %s</p>
            </div>
            
            <span class="badge badge-info">⏰ MAÑANA</span>
            
            <p style="margin-top: 20px; padding: 15px; background-color: #fff3cd; border-radius: 5px; border-left: 4px solid #ffc107;">
                ⚠️ <strong>Importante:</strong> Si no puedes asistir, por favor cancela tu cita desde la aplicación.
            </p>
            
            <p style="margin-top: 20px;">¡Te esperamos!</p>
            """, nombreCliente, nombreBarberia, direccion, nombreBarbero, fechaHora, servicio) + FOOTER;
    }

    public static String plantillaBienvenida(String nombreUsuario) {
        return HEADER + String.format("""
            <h2>¡Bienvenido a BookCut! 🎉</h2>
            <p>Hola <strong>%s</strong>,</p>
            <p>Nos alegra tenerte con nosotros. Tu cuenta ha sido creada exitosamente.</p>
            
            <div class="info-box">
                <p><strong>✅ Cuenta creada</strong></p>
                <p><strong>✅ Perfil configurado</strong></p>
                <p><strong>✅ Listo para reservar</strong></p>
            </div>
            
            <p style="margin-top: 20px;">Ahora puedes:</p>
            <ul>
                <li>📍 Explorar barberías cercanas</li>
                <li>📅 Reservar citas fácilmente</li>
                <li>💈 Elegir tu barbero favorito</li>
                <li>⭐ Ver servicios y precios</li>
            </ul>
            
            <p style="margin-top: 30px; text-align: center;">
                <a href="#" class="button">Explorar Barberías</a>
            </p>
            """, nombreUsuario) + FOOTER;
    }
}