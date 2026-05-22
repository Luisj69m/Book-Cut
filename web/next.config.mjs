/** @type {import('next').NextConfig} */
const nextConfig = {
  // Leemos la IP de las variables de entorno, y si no existe, no ponemos nada
  allowedDevOrigins: process.env.MI_IP_LOCAL ? [process.env.MI_IP_LOCAL] : [],
};

export default nextConfig;
