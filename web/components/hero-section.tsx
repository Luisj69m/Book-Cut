"use client";

import Image from "next/image";
import { Menu, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

export function HeroSection() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <section className="relative min-h-screen flex flex-col overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 0.5, scale: 1 }}
          transition={{ duration: 2 }}
          className="absolute top-20 left-10 w-72 h-72 bg-salmon/20 rounded-full blur-3xl"
        />
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 0.5, scale: 1 }}
          transition={{ duration: 2, delay: 0.5 }}
          className="absolute bottom-40 right-10 w-96 h-96 bg-purple-vibrant/20 rounded-full blur-3xl"
        />
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.3 }}
          transition={{ duration: 2, delay: 1 }}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-lilac/10 rounded-full blur-3xl"
        />
        {/* Floating particles */}
        {[...Array(6)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-salmon/40 rounded-full"
            style={{
              left: `${15 + i * 15}%`,
              top: `${20 + (i % 3) * 25}%`,
            }}
            animate={{
              y: [0, -30, 0],
              opacity: [0.4, 1, 0.4],
            }}
            transition={{
              duration: 3 + i * 0.5,
              repeat: Infinity,
              delay: i * 0.3,
            }}
          />
        ))}
      </div>

      {/* Navigation */}
      <motion.nav
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="relative z-50 w-full px-4 sm:px-6 py-4 flex items-center justify-between"
      >
        <motion.div
          className="flex items-center gap-2"
          whileHover={{ scale: 1.05 }}
        >
          <motion.div
            whileHover={{ rotate: 360 }}
            transition={{ duration: 0.6 }}
          >
            <Image
              src="/logo.png"
              alt="Book&Cut Logo"
              width={40}
              height={40}
              className="rounded-xl"
            />
          </motion.div>
          <span className="text-lg sm:text-xl font-bold text-foreground">
            Book&Cut
          </span>
        </motion.div>

        {/* Desktop Navigation */}
        <div className="hidden md:flex items-center gap-8">
          {["Para Barberos", "Para Clientes", "Descargar"].map((item, i) => (
            <motion.a
              key={item}
              href={`#${item.toLowerCase().replace("para ", "")}`}
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 + i * 0.1 }}
              className="text-muted-foreground hover:text-foreground transition-colors relative group"
            >
              {item}
              <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-salmon group-hover:w-full transition-all duration-300" />
            </motion.a>
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.5 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          {/*  BOTÓN DE DESCARGA 1: Menú Desktop */}
          <a href="/bookcut.apk" download="BookCut.apk">
            <Button className="hidden md:flex neon-button bg-salmon hover:bg-salmon/90 text-white font-semibold">
              Descargar APK
            </Button>
          </a>
        </motion.div>

        {/* Mobile menu button */}
        <motion.button
          whileTap={{ scale: 0.9 }}
          className="md:hidden text-foreground p-2"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          {mobileMenuOpen ? (
            <X className="w-6 h-6" />
          ) : (
            <Menu className="w-6 h-6" />
          )}
        </motion.button>
      </motion.nav>

      {/* Mobile Navigation */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
            className="md:hidden glass-card mx-4 p-4 space-y-4 relative z-40"
          >
            {["Para Barberos", "Para Clientes", "Descargar"].map((item, i) => (
              <motion.a
                key={item}
                href={`#${item.toLowerCase().replace("para ", "")}`}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.1 }}
                className="block text-muted-foreground hover:text-foreground transition-colors"
                onClick={() => setMobileMenuOpen(false)}
              >
                {item}
              </motion.a>
            ))}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
            >
              {/*  BOTÓN DE DESCARGA 2: Menú Móvil */}
              <a
                href="/bookcut.apk"
                download="BookCut.apk"
                className="block w-full"
              >
                <Button className="w-full neon-button bg-salmon hover:bg-salmon/90 text-white font-semibold">
                  Descargar APK
                </Button>
              </a>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Hero Content */}
      <div className="flex-1 flex items-center justify-center px-4 sm:px-6 py-12 sm:py-20 relative z-10">
        <div className="max-w-4xl mx-auto text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3 }}
            className="inline-flex items-center gap-2 glass-card px-3 sm:px-4 py-2 mb-6 sm:mb-8"
          >
            <motion.span
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="w-2 h-2 rounded-full bg-salmon"
            />
            <span className="text-xs sm:text-sm text-muted-foreground">
              La revolución de las barberías ya está aquí
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="text-3xl sm:text-4xl md:text-6xl lg:text-7xl font-bold leading-tight mb-4 sm:mb-6 text-balance"
          >
            Tu barbería favorita,{" "}
            <span className="text-gradient">a un clic de distancia</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.7 }}
            className="text-base sm:text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto mb-8 sm:mb-10 leading-relaxed px-2"
          >
            Book&Cut es la plataforma definitiva para la gestión de citas en
            barberías. Conecta a barberos profesionales con clientes que buscan
            un servicio de calidad,
            <span className="text-foreground font-medium">
              {" "}
              eliminando las esperas y las llamadas telefónicas
            </span>
            .
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.9 }}
            className="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-center px-4 sm:px-0"
          >
            <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
              {/*  BOTÓN DE DESCARGA 3: Botón Principal Central */}
              <a
                href="/bookcut.apk"
                download="BookCut.apk"
                className="block w-full sm:inline-block sm:w-auto"
              >
                <Button
                  size="lg"
                  className="neon-button bg-salmon hover:bg-salmon/90 text-white font-semibold text-base sm:text-lg px-6 sm:px-8 py-5 sm:py-6 w-full sm:w-auto animate-pulse-glow"
                >
                  Descargar para Android
                </Button>
              </a>
            </motion.div>
            <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
              <Button
                size="lg"
                variant="outline"
                className="glass-card border-glass-border text-foreground hover:bg-glass hover:text-foreground px-6 sm:px-8 py-5 sm:py-6 w-full sm:w-auto"
              >
                Ver cómo funciona
              </Button>
            </motion.div>
          </motion.div>

          {/* Value Propositions */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1.1 }}
            className="mt-12 sm:mt-16 grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6 max-w-2xl mx-auto px-4 sm:px-0"
          >
            {[
              {
                value: "0",
                label: "Llamadas necesarias",
                color: "text-salmon",
              },
              {
                value: "24/7",
                label: "Siempre disponible",
                color: "text-lilac",
              },
              {
                value: "0%",
                label: "Comisiones",
                color: "text-purple-vibrant",
              },
            ].map((stat, i) => (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 1.3 + i * 0.2 }}
                whileHover={{ scale: 1.1, y: -5 }}
                className="glass-card p-4 text-center"
              >
                <p
                  className={`text-2xl sm:text-3xl md:text-4xl font-bold ${stat.color}`}
                >
                  {stat.value}
                </p>
                <p className="text-xs sm:text-sm text-muted-foreground">
                  {stat.label}
                </p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>

      {/* Scroll indicator - hidden on mobile */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2 }}
        className="hidden sm:block absolute bottom-8 left-1/2 -translate-x-1/2"
      >
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ duration: 1.5, repeat: Infinity }}
          className="w-6 h-10 rounded-full border-2 border-muted-foreground/50 flex justify-center pt-2"
        >
          <motion.div
            animate={{ opacity: [1, 0, 1] }}
            transition={{ duration: 1.5, repeat: Infinity }}
            className="w-1 h-3 rounded-full bg-salmon"
          />
        </motion.div>
      </motion.div>
    </section>
  );
}
