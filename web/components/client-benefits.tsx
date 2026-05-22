"use client"

import { Clock, DollarSign, Heart, Bell } from "lucide-react"
import { motion } from "framer-motion"

export function ClientBenefits() {
  const benefits = [
    {
      icon: Clock,
      title: "Reservas 24/7",
      description: "Reserva tu cita a cualquier hora del día o la noche, sin necesidad de llamar por teléfono. Tu barbería siempre disponible."
    },
    {
      icon: DollarSign,
      title: "Información transparente",
      description: "Conoce el servicio exacto, precio y duración antes de reservar. Sin sorpresas al momento de pagar."
    },
    {
      icon: Heart,
      title: "Elige tu barbero favorito",
      description: "Selecciona al profesional que más te guste dentro del local. Crea una relación duradera con tu barbero de confianza."
    },
    {
      icon: Bell,
      title: "Historial y recordatorios",
      description: "Accede a tu historial de citas y recibe recordatorios automáticos. Nunca más olvides un corte de pelo."
    }
  ]

  return (
    <section className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      {/* Background accent */}
      <motion.div 
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        className="absolute inset-0 bg-gradient-to-b from-transparent via-lilac/5 to-transparent pointer-events-none" 
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
            <span className="text-lilac font-semibold text-xs sm:text-sm">PARA CLIENTES</span>
          </motion.div>
          <h2 className="text-2xl sm:text-3xl md:text-5xl font-bold mb-4 text-balance">
            ¿Qué consigue el <span className="text-lilac">Cliente</span>?
          </h2>
          <p className="text-muted-foreground text-base sm:text-lg max-w-2xl mx-auto px-2">
            Una experiencia de reserva sencilla, rápida y sin fricciones. 
            Tu tiempo merece respeto.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
          {benefits.map((benefit, index) => (
            <motion.div 
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ y: -10, scale: 1.05 }}
              className="glass-card p-5 sm:p-6 text-center group hover:border-lilac/50 transition-all duration-300"
            >
              <motion.div 
                whileHover={{ rotate: 360, scale: 1.1 }}
                transition={{ duration: 0.5 }}
                className="w-12 sm:w-14 h-12 sm:h-14 rounded-2xl bg-gradient-to-br from-lilac/20 to-lilac/5 flex items-center justify-center mx-auto mb-3 sm:mb-4 group-hover:from-lilac/30 group-hover:to-lilac/10 transition-all duration-300"
              >
                <benefit.icon className="w-6 sm:w-7 h-6 sm:h-7 text-lilac" />
              </motion.div>
              <h3 className="text-base sm:text-lg font-semibold mb-2 group-hover:text-lilac transition-colors">{benefit.title}</h3>
              <p className="text-muted-foreground text-xs sm:text-sm leading-relaxed">{benefit.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
