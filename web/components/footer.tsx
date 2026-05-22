"use client"

import Image from "next/image"
import { motion } from "framer-motion"

export function Footer() {
  return (
    <motion.footer 
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true }}
      transition={{ duration: 0.6 }}
      className="py-8 sm:py-12 px-4 sm:px-6 border-t border-border"
    >
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <motion.div 
            whileHover={{ scale: 1.05 }}
            className="flex items-center gap-2"
          >
            <Image 
              src="/logo.png" 
              alt="Book&Cut Logo" 
              width={32} 
              height={32}
              className="rounded-lg"
            />
            <span className="text-lg font-bold text-foreground">Book&Cut</span>
          </motion.div>

          <div className="flex flex-wrap justify-center gap-4 sm:gap-6 text-sm text-muted-foreground">
            {["Política de Privacidad", "Términos de Uso", "Contacto", "Soporte"].map((item, i) => (
              <motion.a 
                key={item}
                href="#"
                initial={{ opacity: 0, y: 10 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.1 }}
                whileHover={{ scale: 1.1, color: "#E96D71" }}
                className="hover:text-foreground transition-colors"
              >
                {item}
              </motion.a>
            ))}
          </div>

          <motion.p 
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            transition={{ delay: 0.4 }}
            className="text-sm text-muted-foreground text-center"
          >
            © 2025 Book&Cut. Todos los derechos reservados.
          </motion.p>
        </div>
      </div>
    </motion.footer>
  )
}
