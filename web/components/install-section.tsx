"use client"

import { Download, Settings, FileCheck, Rocket, Smartphone, Wifi, Check } from "lucide-react"
import { motion } from "framer-motion"

export function InstallSection() {
  const steps = [
    {
      number: "01",
      icon: Download,
      title: "Descarga el archivo APK",
      description: "Haz clic en el botón de descarga y guarda el archivo .apk en tu dispositivo Android."
    },
    {
      number: "02",
      icon: Settings,
      title: "Habilita orígenes desconocidos",
      description: "Ve a Ajustes > Seguridad > Instalar aplicaciones de orígenes desconocidos y actívalo."
    },
    {
      number: "03",
      icon: FileCheck,
      title: "Instala la aplicación",
      description: "Abre el archivo descargado y presiona 'Instalar'. Espera a que se complete el proceso."
    },
    {
      number: "04",
      icon: Rocket,
      title: "¡Listo para usar!",
      description: "Crea tu cuenta y empieza a reservar o gestionar tu barbería en segundos."
    }
  ]

  const requirements = [
    { icon: Smartphone, text: "Android 8.0 o superior" },
    { icon: Wifi, text: "Conexión a internet" }
  ]

  return (
    <section id="descargar" className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      {/* Animated background elements */}
      <motion.div
        animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.5, 0.3] }}
        transition={{ duration: 8, repeat: Infinity }}
        className="absolute top-0 right-0 w-96 h-96 bg-purple-vibrant/10 rounded-full blur-3xl pointer-events-none"
      />
      <motion.div
        animate={{ scale: [1.2, 1, 1.2], opacity: [0.3, 0.5, 0.3] }}
        transition={{ duration: 8, repeat: Infinity, delay: 4 }}
        className="absolute bottom-0 left-0 w-96 h-96 bg-salmon/10 rounded-full blur-3xl pointer-events-none"
      />

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12 sm:mb-16"
        >
          <motion.div 
            initial={{ opacity: 0, scale: 0.8 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            className="inline-flex items-center gap-2 glass-card px-3 sm:px-4 py-2 mb-4 sm:mb-6"
          >
            <span className="text-purple-vibrant font-semibold text-xs sm:text-sm">INSTALACIÓN</span>
          </motion.div>
          <h2 className="text-2xl sm:text-3xl md:text-5xl font-bold mb-4 text-balance">
            ¿Cómo se <span className="text-gradient">instala</span>?
          </h2>
          <p className="text-muted-foreground text-base sm:text-lg max-w-2xl mx-auto px-2">
            Sigue estos sencillos pasos para tener Book&Cut funcionando en tu dispositivo Android.
          </p>
        </motion.div>

        {/* Requirements */}
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="glass-card p-4 sm:p-6 mb-8 sm:mb-12 max-w-xl mx-auto"
        >
          <h3 className="text-base sm:text-lg font-semibold mb-4 text-center">Requisitos mínimos</h3>
          <div className="flex flex-col sm:flex-row justify-center gap-4 sm:gap-6">
            {requirements.map((req, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, x: index === 0 ? -20 : 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ delay: 0.2 + index * 0.1 }}
                className="flex items-center gap-3"
              >
                <motion.div 
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                  className="w-10 h-10 rounded-xl bg-purple-vibrant/20 flex items-center justify-center shrink-0"
                >
                  <req.icon className="w-5 h-5 text-purple-vibrant" />
                </motion.div>
                <span className="text-foreground text-sm sm:text-base">{req.text}</span>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* Steps */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {steps.map((step, index) => (
            <motion.div 
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.5, delay: index * 0.15 }}
              whileHover={{ scale: 1.05, y: -10 }}
              className="glass-card p-5 sm:p-6 relative group hover:border-purple-vibrant/50 transition-all duration-300"
            >
              <motion.span 
                initial={{ scale: 0 }}
                whileInView={{ scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: 0.3 + index * 0.15, type: "spring" }}
                className="absolute -top-3 -left-3 w-8 h-8 rounded-lg bg-gradient-to-br from-salmon to-purple-vibrant flex items-center justify-center text-xs font-bold text-white"
              >
                {step.number}
              </motion.span>
              <motion.div 
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.6 }}
                className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-vibrant/20 to-purple-vibrant/5 flex items-center justify-center mb-4 group-hover:from-purple-vibrant/30 group-hover:to-purple-vibrant/10 transition-all duration-300"
              >
                <step.icon className="w-6 h-6 text-purple-vibrant" />
              </motion.div>
              <h3 className="text-base sm:text-lg font-semibold mb-2 group-hover:text-purple-vibrant transition-colors">{step.title}</h3>
              <p className="text-muted-foreground text-xs sm:text-sm leading-relaxed">{step.description}</p>
            </motion.div>
          ))}
        </div>

        {/* FAQ Note */}
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          whileHover={{ scale: 1.02 }}
          className="mt-8 sm:mt-12 glass-card p-4 sm:p-6 max-w-2xl mx-auto"
        >
          <div className="flex items-start gap-3 sm:gap-4">
            <motion.div 
              animate={{ rotate: [0, 10, -10, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="w-10 h-10 rounded-xl bg-salmon/20 flex items-center justify-center shrink-0"
            >
              <Check className="w-5 h-5 text-salmon" />
            </motion.div>
            <div>
              <h4 className="font-semibold mb-1 text-sm sm:text-base">¿Es seguro instalar la APK?</h4>
              <p className="text-muted-foreground text-xs sm:text-sm leading-relaxed">
                Sí, Book&Cut es completamente seguro. La APK está firmada digitalmente y no contiene malware. 
                Estamos trabajando para publicar la app en Google Play Store próximamente.
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
