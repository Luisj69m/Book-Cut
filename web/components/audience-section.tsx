"use client"

import { Store, Clock, UserCheck, Smartphone } from "lucide-react"
import { motion } from "framer-motion"

export function AudienceSection() {
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.3 }
    }
  }

  const cardVariants = {
    hidden: { opacity: 0, y: 50 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  }

  return (
    <section className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      {/* Animated background circles */}
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 60, repeat: Infinity, ease: "linear" }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] border border-glass-border/20 rounded-full pointer-events-none"
      />
      <motion.div
        animate={{ rotate: -360 }}
        transition={{ duration: 45, repeat: Infinity, ease: "linear" }}
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] border border-glass-border/30 rounded-full pointer-events-none"
      />

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12 sm:mb-16"
        >
          <h2 className="text-2xl sm:text-3xl md:text-5xl font-bold mb-4 text-balance">
            ¿Para quién es <span className="text-gradient">Book&Cut</span>?
          </h2>
          <p className="text-muted-foreground text-base sm:text-lg max-w-2xl mx-auto px-2">
            Una solución diseñada para dos tipos de usuarios que comparten el mismo objetivo: 
            optimizar el tiempo y disfrutar de la mejor experiencia.
          </p>
        </motion.div>

        <motion.div 
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="grid md:grid-cols-2 gap-6 sm:gap-8"
        >
          {/* For Barbers */}
          <motion.div 
            id="barberos" 
            variants={cardVariants}
            whileHover={{ scale: 1.02, y: -10 }}
            transition={{ duration: 0.3 }}
            className="glass-card p-6 sm:p-8 group hover:border-salmon/50 transition-all duration-300 relative overflow-hidden"
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-salmon/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"
            />
            <div className="relative z-10">
              <motion.div 
                whileHover={{ rotate: 360 }}
                transition={{ duration: 0.6 }}
                className="w-14 sm:w-16 h-14 sm:h-16 rounded-2xl bg-gradient-to-br from-salmon/20 to-salmon/5 flex items-center justify-center mb-4 sm:mb-6 group-hover:glow-salmon transition-all duration-300"
              >
                <Store className="w-7 sm:w-8 h-7 sm:h-8 text-salmon" />
              </motion.div>
              <h3 className="text-xl sm:text-2xl font-bold mb-3 sm:mb-4 group-hover:text-salmon transition-colors">Para Barberías y Barberos Independientes</h3>
              <p className="text-muted-foreground mb-4 sm:mb-6 leading-relaxed text-sm sm:text-base">
                ¿Cansado de agendas desorganizadas y clientes que no se presentan? 
                Book&Cut te ayuda a digitalizar tu negocio, organizar tu agenda y reducir las ausencias drásticamente.
              </p>
              <ul className="space-y-3">
                {[
                  { icon: Clock, text: "Digitaliza tu negocio en minutos" },
                  { icon: UserCheck, text: "Reduce ausencias con recordatorios" },
                  { icon: Store, text: "Organiza tu agenda profesionalmente" }
                ].map((item, i) => (
                  <motion.li 
                    key={item.text}
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: 0.5 + i * 0.1 }}
                    className="flex items-center gap-3"
                  >
                    <motion.div 
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 2, repeat: Infinity, delay: i * 0.2 }}
                      className="w-6 h-6 rounded-full bg-salmon/20 flex items-center justify-center shrink-0"
                    >
                      <item.icon className="w-3 h-3 text-salmon" />
                    </motion.div>
                    <span className="text-foreground text-sm sm:text-base">{item.text}</span>
                  </motion.li>
                ))}
              </ul>
            </div>
          </motion.div>

          {/* For Clients */}
          <motion.div 
            id="clientes" 
            variants={cardVariants}
            whileHover={{ scale: 1.02, y: -10 }}
            transition={{ duration: 0.3 }}
            className="glass-card p-6 sm:p-8 group hover:border-lilac/50 transition-all duration-300 relative overflow-hidden"
          >
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-lilac/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"
            />
            <div className="relative z-10">
              <motion.div 
                whileHover={{ scale: 1.2 }}
                transition={{ duration: 0.3 }}
                className="w-14 sm:w-16 h-14 sm:h-16 rounded-2xl bg-gradient-to-br from-lilac/20 to-lilac/5 flex items-center justify-center mb-4 sm:mb-6 group-hover:glow-purple transition-all duration-300"
              >
                <Smartphone className="w-7 sm:w-8 h-7 sm:h-8 text-lilac" />
              </motion.div>
              <h3 className="text-xl sm:text-2xl font-bold mb-3 sm:mb-4 group-hover:text-lilac transition-colors">Para Clientes Exigentes</h3>
              <p className="text-muted-foreground mb-4 sm:mb-6 leading-relaxed text-sm sm:text-base">
                Tu tiempo es valioso. Olvídate de llamar por teléfono o esperar en cola. 
                Con Book&Cut reservas tu corte de pelo en solo 3 clics desde tu móvil.
              </p>
              <ul className="space-y-3">
                {[
                  { icon: Smartphone, text: "Reserva en 3 clics desde tu móvil" },
                  { icon: Clock, text: "Sin esperas, sin llamadas" },
                  { icon: UserCheck, text: "Elige a tu barbero favorito" }
                ].map((item, i) => (
                  <motion.li 
                    key={item.text}
                    initial={{ opacity: 0, x: -20 }}
                    whileInView={{ opacity: 1, x: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: 0.5 + i * 0.1 }}
                    className="flex items-center gap-3"
                  >
                    <motion.div 
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 2, repeat: Infinity, delay: i * 0.2 }}
                      className="w-6 h-6 rounded-full bg-lilac/20 flex items-center justify-center shrink-0"
                    >
                      <item.icon className="w-3 h-3 text-lilac" />
                    </motion.div>
                    <span className="text-foreground text-sm sm:text-base">{item.text}</span>
                  </motion.li>
                ))}
              </ul>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  )
}
