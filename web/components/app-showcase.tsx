"use client"

import { motion } from "framer-motion"
import Image from "next/image"

export function AppShowcase() {
  return (
    <section className="py-16 sm:py-24 px-4 relative overflow-hidden">
      {/* Background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <motion.div
          className="absolute top-1/4 left-1/4 w-96 h-96 bg-salmon/10 rounded-full blur-3xl"
          animate={{
            scale: [1, 1.2, 1],
            x: [0, 50, 0],
          }}
          transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div
          className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-vibrant/10 rounded-full blur-3xl"
          animate={{
            scale: [1.2, 1, 1.2],
            x: [0, -50, 0],
          }}
          transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
        />
      </div>

      <div className="max-w-6xl mx-auto relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12 sm:mb-16"
        >
          <motion.span
            initial={{ opacity: 0, scale: 0.8 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
            className="inline-block px-4 py-2 rounded-full bg-lilac/20 text-lilac text-sm font-medium mb-4"
          >
            Vista Previa
          </motion.span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 text-balance">
            Diseño{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-salmon to-lilac">
              Moderno e Intuitivo
            </span>
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto leading-relaxed">
            Una interfaz elegante y fácil de usar, diseñada para que gestionar tus citas sea una experiencia agradable
          </p>
        </motion.div>

        <div className="flex flex-col lg:flex-row items-center justify-center gap-8 lg:gap-16">
          {/* Phone mockup */}
          <motion.div
            initial={{ opacity: 0, x: -50, rotateY: -15 }}
            whileInView={{ opacity: 1, x: 0, rotateY: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, type: "spring", stiffness: 100 }}
            className="relative"
          >
            {/* Glow effect behind phone */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-br from-salmon/30 via-purple-vibrant/30 to-lilac/30 rounded-[3rem] blur-2xl"
              animate={{
                scale: [1, 1.05, 1],
                opacity: [0.5, 0.8, 0.5],
              }}
              transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
            />
            
            {/* Phone frame */}
            <motion.div
              className="relative z-10 rounded-[2.5rem] p-2 bg-gradient-to-br from-gray-800 to-gray-900 shadow-2xl"
              whileHover={{ scale: 1.02, rotateY: 5 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              <div className="relative rounded-[2rem] overflow-hidden bg-black">
                {/* Notch */}
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-6 bg-black rounded-b-2xl z-20" />
                
                {/* Screenshot */}
                <motion.div
                  initial={{ scale: 1.1 }}
                  whileInView={{ scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 1, ease: "easeOut" }}
                >
                  {/*  IMAGEN ACTUALIZADA A ALTA CALIDAD */}
                  <Image
                    src="/login.png"
                    alt="Book&Cut App - Pantalla de inicio de sesión"
                    width={280}
                    height={600}
                    className="w-[280px] sm:w-[300px] h-auto"
                    priority
                  />
                </motion.div>
              </div>
            </motion.div>

            {/* Floating elements around phone */}
            {/*  CAJITA SEGURO REPOSICIONADA HACIA AFUERA  */}
            <motion.div
              className="absolute -top-6 -right-6 sm:-right-16 lg:-right-20 z-20 glass-card p-3 rounded-xl"
              initial={{ opacity: 0, scale: 0 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5, type: "spring" }}
              animate={{ y: [0, -10, 0], transition: { duration: 2, repeat: Infinity, ease: "easeInOut" } }}
            >
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center">
                  <svg className="w-4 h-4 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <span className="text-sm font-medium text-foreground">Seguro</span>
              </div>
            </motion.div>

            {/*  CAJITA RÁPIDO REPOSICIONADA HACIA AFUERA */}
            <motion.div
              className="absolute -bottom-6 -left-6 sm:-left-16 lg:-left-20 z-20 glass-card p-3 rounded-xl"
              initial={{ opacity: 0, scale: 0 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.7, type: "spring" }}
              animate={{ y: [0, 10, 0], transition: { duration: 2.5, repeat: Infinity, ease: "easeInOut" } }}
            >
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-salmon/20 flex items-center justify-center">
                  <svg className="w-4 h-4 text-salmon" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                  </svg>
                </div>
                <span className="text-sm font-medium text-foreground">Rápido</span>
              </div>
            </motion.div>
          </motion.div>

          {/* Features list */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="max-w-md"
          >
            <div className="space-y-6">
              {[
                {
                  icon: (
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                    </svg>
                  ),
                  title: "Inicio de sesión seguro",
                  description: "Protección de datos con autenticación moderna"
                },
                {
                  icon: (
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" />
                    </svg>
                  ),
                  title: "Diseño glassmorphism",
                  description: "Interfaz moderna con efectos de cristal"
                },
                {
                  icon: (
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                    </svg>
                  ),
                  title: "Optimizado para móvil",
                  description: "Experiencia fluida en cualquier dispositivo Android"
                },
                {
                  icon: (
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                    </svg>
                  ),
                  title: "Acceso instantáneo",
                  description: "Registro rápido y navegación intuitiva"
                }
              ].map((feature, index) => (
                <motion.div
                  key={feature.title}
                  initial={{ opacity: 0, x: 30 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: 0.4 + index * 0.1 }}
                  whileHover={{ x: 10 }}
                  className="flex items-start gap-4 group"
                >
                  <motion.div
                    className="w-12 h-12 rounded-xl bg-gradient-to-br from-salmon/20 to-purple-vibrant/20 flex items-center justify-center text-salmon shrink-0"
                    whileHover={{ scale: 1.1, rotate: 5 }}
                  >
                    {feature.icon}
                  </motion.div>
                  <div>
                    <h3 className="font-semibold text-foreground mb-1 group-hover:text-salmon transition-colors">
                      {feature.title}
                    </h3>
                    <p className="text-muted-foreground text-sm leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}