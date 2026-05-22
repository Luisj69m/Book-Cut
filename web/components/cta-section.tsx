"use client"

import Image from "next/image"
import { Download, Sparkles } from "lucide-react"
import { Button } from "@/components/ui/button"
import { motion } from "framer-motion"

export function CTASection() {
  return (
    <section className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      {/* Animated background */}
      <motion.div
        animate={{
          background: [
            "radial-gradient(circle at 30% 50%, rgba(233, 109, 113, 0.15) 0%, transparent 50%)",
            "radial-gradient(circle at 70% 50%, rgba(233, 109, 113, 0.15) 0%, transparent 50%)",
            "radial-gradient(circle at 30% 50%, rgba(233, 109, 113, 0.15) 0%, transparent 50%)",
          ],
        }}
        transition={{ duration: 10, repeat: Infinity }}
        className="absolute inset-0 pointer-events-none"
      />

      {/* Floating particles */}
      {[...Array(8)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1 h-1 bg-salmon/60 rounded-full"
          style={{
            left: `${10 + i * 12}%`,
            top: `${30 + (i % 4) * 15}%`,
          }}
          animate={{
            y: [0, -40, 0],
            opacity: [0.3, 1, 0.3],
            scale: [1, 1.5, 1],
          }}
          transition={{
            duration: 4 + i * 0.3,
            repeat: Infinity,
            delay: i * 0.4,
          }}
        />
      ))}

      <div className="max-w-4xl mx-auto relative z-10">
        <motion.div 
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.8 }}
          className="glass-card p-6 sm:p-8 md:p-12 text-center relative overflow-hidden"
        >
          {/* Shimmer effect */}
          <div className="absolute inset-0 animate-shimmer pointer-events-none" />

          {/* Inner glow */}
          <div className="absolute inset-0 bg-gradient-to-br from-salmon/10 via-transparent to-purple-vibrant/10 pointer-events-none" />

          <div className="relative">
            <motion.div 
              initial={{ scale: 0 }}
              whileInView={{ scale: 1 }}
              viewport={{ once: true }}
              transition={{ type: "spring", delay: 0.3 }}
              className="w-20 sm:w-24 h-20 sm:h-24 rounded-full mx-auto mb-4 sm:mb-6 animate-pulse-glow"
            >
              <Image 
                src="/logo.png" 
                alt="Book&Cut Logo" 
                width={96} 
                height={96}
                className="w-full h-full object-contain rounded-full"
              />
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.4 }}
              className="inline-flex items-center gap-2 mb-4"
            >
              <motion.div
                animate={{ rotate: [0, 360] }}
                transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
              >
                <Sparkles className="w-5 h-5 text-salmon" />
              </motion.div>
              <span className="text-salmon text-sm font-medium uppercase tracking-wider">
                Comienza hoy
              </span>
              <motion.div
                animate={{ rotate: [0, -360] }}
                transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
              >
                <Sparkles className="w-5 h-5 text-salmon" />
              </motion.div>
            </motion.div>

            <motion.h2 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5 }}
              className="text-2xl sm:text-3xl md:text-5xl font-bold mb-4 text-balance"
            >
              Únete a la <span className="text-gradient">revolución</span>
            </motion.h2>
            
            <motion.p 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.6 }}
              className="text-muted-foreground text-base sm:text-lg max-w-xl mx-auto mb-6 sm:mb-8 leading-relaxed px-2"
            >
              Descarga Book&Cut hoy y descubre una nueva forma de gestionar tus citas. 
              Sin comisiones, sin complicaciones.
            </motion.p>

            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.7 }}
              className="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-center mb-6 sm:mb-8 px-4 sm:px-0"
            >
              <motion.div
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {/*  Descarga Final */}
                <a href="/bookcut.apk" download="BookCut.apk" className="block w-full sm:inline-block sm:w-auto">
                  <Button 
                    size="lg"
                    className="neon-button bg-salmon hover:bg-salmon/90 text-white font-bold text-base sm:text-lg px-8 sm:px-10 py-6 sm:py-7 w-full sm:w-auto animate-pulse-glow"
                  >
                    <Download className="w-5 h-5 mr-2" />
                    Descargar APK Ahora
                  </Button>
                </a>
              </motion.div>
            </motion.div>

            <motion.p 
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.9 }}
              className="text-muted-foreground text-xs sm:text-sm"
            >
              Gratis  •  Sin publicidad  •  Actualizaciones automáticas
            </motion.p>
          </div>
        </motion.div>
      </div>
    </section>
  )
}