import { HeroSection } from "@/components/hero-section"
import { AudienceSection } from "@/components/audience-section"
import { AppShowcase } from "@/components/app-showcase"
import { BarberBenefits } from "@/components/barber-benefits"
import { ClientBenefits } from "@/components/client-benefits"
import { InstallSection } from "@/components/install-section"
import { CTASection } from "@/components/cta-section"
import { Footer } from "@/components/footer"

export default function Home() {
  return (
    <main className="min-h-screen overflow-hidden relative">
      {/* Background gradient orbs */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-purple-vibrant/30 rounded-full blur-3xl" />
        <div className="absolute top-1/3 -left-40 w-80 h-80 bg-salmon/20 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-72 h-72 bg-lilac/20 rounded-full blur-3xl" />
        <div className="absolute -bottom-20 left-1/3 w-96 h-96 bg-purple-vibrant/20 rounded-full blur-3xl" />
      </div>

      {/* Content */}
      <div className="relative z-10">
        <HeroSection />
        <AudienceSection />
        <AppShowcase />
        <BarberBenefits />
        <ClientBenefits />
        <InstallSection />
        <CTASection />
        <Footer />
      </div>
    </main>
  )
}
