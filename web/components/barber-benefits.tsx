"use client"

import { Calendar, BarChart3, CheckCircle2, UserCircle } from "lucide-react"
import { motion } from "framer-motion"

export function BarberBenefits() {
  const benefits = [
    {
      icon: Calendar,
      title: "Control total de la agenda",
      description: "Gestiona todas tus citas en tiempo real desde cualquier dispositivo. Visualiza tu día, semana o mes de un vistazo."
    },
    {
      icon: BarChart3,
      title: "Panel de métricas y ganancias",
      description: "Accede a estadísticas detalladas de tus servicios, clientes recurrentes e ingresos. Toma decisiones basadas en datos reales."
    },
    {
      icon: CheckCircle2,
      title: "Gestión flexible de citas",
      description: "Acepta, rechaza o reprograma citas con un solo toque. Notifica a tus clientes automáticamente de cualquier cambio."
    },
    {
      icon: UserCircle,
      title: "Perfil profesional propio",
      description: "Crea tu perfil dentro de la barbería para fidelizar a tus propios clientes. Muestra tu portfolio y especialidades."
    }
  ]

  return (
    <section className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      {/* Background accent */}
      <motion.div 
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        className="absolute inset-0 bg-gradient-to-b from-transparent via-salmon/5 to-transparent pointer-events-none" 
      />

      <div className="max-w-6xl mx-auto relative">
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
            <span className="text-salmon font-semibold text-xs sm:text-sm">PARA PROFESIONALES</span>
          </motion.div>
          <h2 className="text-2xl sm:text-3xl md:text-5xl font-bold mb-4 text-balance">
            ¿Qué consigue el <span className="text-salmon">Barbero</span>?
          </h2>
          <p className="text-muted-foreground text-base sm:text-lg max-w-2xl mx-auto px-2">
            Herramientas diseñadas para que te centres en lo que mejor sabes hacer: 
            crear estilos increíbles.
          </p>
        </motion.div>

        <div className="grid sm:grid-cols-2 gap-4 sm:gap-6">
          {benefits.map((benefit, index) => (
            <motion.div 
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ scale: 1.02, y: -5 }}
              className="glass-card p-5 sm:p-6 group hover:border-salmon/50 transition-all duration-300"
            >
              <div className="flex items-start gap-3 sm:gap-4">
                <motion.div 
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.6 }}
                  className="w-11 sm:w-12 h-11 sm:h-12 rounded-xl bg-gradient-to-br from-salmon/20 to-salmon/5 flex items-center justify-center shrink-0 group-hover:from-salmon/30 group-hover:to-salmon/10 transition-all duration-300"
                >
                  <benefit.icon className="w-5 sm:w-6 h-5 sm:h-6 text-salmon" />
                </motion.div>
                <div>
                  <h3 className="text-lg sm:text-xl font-semibold mb-2 group-hover:text-salmon transition-colors">{benefit.title}</h3>
                  <p className="text-muted-foreground leading-relaxed text-sm sm:text-base">{benefit.description}</p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
