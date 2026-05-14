import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../utils/glass_toast.dart';
import 'settings_screen.dart';

class EarningsBarberScreen extends StatefulWidget {
  final int idUsuarioBarbero; // ✅ AÑADIDO PARA PODER ABRIR LOS AJUSTES

  const EarningsBarberScreen({super.key, required this.idUsuarioBarbero});

  @override
  State<EarningsBarberScreen> createState() => _EarningsBarberScreenState();
}

class _EarningsBarberScreenState extends State<EarningsBarberScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  double _totalIngresos = 0.0;
  List<dynamic> _citasDetalle = [];

  // Datos procesados para el gráfico
  Map<int, double> _ingresosPorMes = {};

  // Colores corporativos (Paleta Dark Mode)
  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);
  final accentLilac = const Color(0xFFB388FF);
  final neonCyan = const Color(0xFF40C4FF);
  final neonGreen = Colors.greenAccent;

  static const _meses = ['', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

  @override
  void initState() {
    super.initState();
    _cargarDatosFacturacion();
  }

  Future<void> _cargarDatosFacturacion() async {
    setState(() => _isLoading = true);
    try {
      final datos = await _apiService.getResumenFacturacion();
      final citas = (datos['citasDetalle'] ?? []) as List<dynamic>;

      // Agrupamos ingresos por mes priorizando precioFinal
      final Map<int, double> porMes = {};
      for (final cita in citas) {
        final double precio = (cita['precioFinal'] ?? cita['servicioContratado']?['precioServicio'] ?? 0.0).toDouble();
        final String fechaRaw = cita['fechaHoraCita'] ?? '';
        if (fechaRaw.isNotEmpty) {
          try {
            final mes = DateTime.parse(fechaRaw).month;
            porMes[mes] = (porMes[mes] ?? 0.0) + precio;
          } catch (_) {}
        }
      }

      if (mounted) {
        setState(() {
          _totalIngresos = (datos['totalIngresos'] ?? 0.0).toDouble();
          _citasDetalle = citas;
          _ingresosPorMes = porMes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GlassToast.showError(context, "Error al cargar datos", e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: _buildGlassmorphicNavBar(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, mainColor, const Color(0xFF1A0A3D)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text("Finanzas", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),

              // ── TARJETA PRINCIPAL (CRISTAL) ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            // ── CABECERA (INGRESOS TOTALES) ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                        color: neonCyan.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: neonCyan, width: 1.5),
                                        boxShadow: [BoxShadow(color: neonCyan.withOpacity(0.3), blurRadius: 10)]
                                    ),
                                    child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Ingresos Totales", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text("Citas cobradas directamente", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  _isLoading
                                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: neonGreen, strokeWidth: 2))
                                      : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: neonGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: neonGreen.withOpacity(0.5), width: 1),
                                    ),
                                    child: Text(
                                      "${_totalIngresos.toStringAsFixed(2).replaceAll('.', ',')} €",
                                      style: TextStyle(color: neonGreen, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── CONTENIDO SCROLLABLE ──
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                  : RefreshIndicator(
                                onRefresh: _cargarDatosFacturacion,
                                color: neonCyan,
                                backgroundColor: mainColor,
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 90), // Espacio para navbar
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    // ── GRÁFICO DE BARRAS ──
                                    if (_ingresosPorMes.isNotEmpty) ...[
                                      _buildGrafico(),
                                      const SizedBox(height: 25),
                                    ],

                                    // ── TÍTULO LISTA ──
                                    Row(
                                      children: [
                                        Container(
                                          width: 4, height: 18,
                                          decoration: BoxDecoration(color: neonCyan, borderRadius: BorderRadius.circular(2)),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text("Detalle de ingresos", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                                      ],
                                    ),
                                    const SizedBox(height: 15),

                                    // ── LISTA DE CITAS ──
                                    if (_citasDetalle.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 40),
                                        child: Column(
                                          children: [
                                            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                                            const SizedBox(height: 12),
                                            Text("Aún no hay citas cobradas", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                                          ],
                                        ),
                                      )
                                    else
                                      ...(_citasDetalle.map((cita) {
                                        final String servicio = cita["servicioContratado"]?["nombreServicio"] ?? "Servicio";
                                        final double precio = (cita["precioFinal"] ?? cita["servicioContratado"]?["precioServicio"] ?? 0.0).toDouble();
                                        final String precioStr = "${precio.toStringAsFixed(2).replaceAll('.', ',')} €";
                                        final String fechaHoraRaw = cita["fechaHoraCita"] ?? "";
                                        final String hora = fechaHoraRaw.contains('T') ? fechaHoraRaw.split('T')[1].substring(0, 5) : "--:--";
                                        String fechaFormateada = "";
                                        try {
                                          if (fechaHoraRaw.isNotEmpty) {
                                            final dt = DateTime.parse(fechaHoraRaw);
                                            fechaFormateada = "${dt.day.toString().padLeft(2, '0')} ${_meses[dt.month]}";
                                          }
                                        } catch (_) {}
                                        return _buildIngresoCard(servicio, precioStr, hora, fechaFormateada);
                                      })),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- GRÁFICO DE BARRAS (ADAPTADO AL DARK GLASSMORPHISM) ---
  Widget _buildGrafico() {
    final mesesConDatos = _ingresosPorMes.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxY = mesesConDatos.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Cristal
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: neonCyan, size: 20),
              const SizedBox(width: 8),
              const Text("Ingresos por mes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.25,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black.withOpacity(0.8), // Tooltip oscuro
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final mes = mesesConDatos[groupIndex].key;
                      return BarTooltipItem(
                        "${_meses[mes]}\n",
                        TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                        children: [
                          TextSpan(
                            text: "${rod.toY.toStringAsFixed(2).replaceAll('.', ',')} €",
                            style: TextStyle(color: neonGreen, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          "${value.toInt()}€",
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= mesesConDatos.length) return const SizedBox();
                        final mes = mesesConDatos[idx].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_meses[mes], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1), // Líneas sutiles
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(mesesConDatos.length, (index) {
                  final entry = mesesConDatos[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [accentLilac, neonCyan], // Degradado de barras neón
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TARJETAS INDIVIDUALES DE INGRESOS ---
  Widget _buildIngresoCard(String servicio, String precio, String hora, String fecha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06), // Tarjeta de cristal
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: neonCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonCyan.withOpacity(0.3))
            ),
            child: Icon(Icons.receipt_rounded, color: neonCyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (fecha.isNotEmpty) ...[
                      Icon(Icons.calendar_today_rounded, size: 11, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(fecha, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                      const SizedBox(width: 10),
                    ],
                    Icon(Icons.access_time_rounded, size: 11, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(hora, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: neonGreen.withOpacity(0.4)),
            ),
            child: Text("+ $precio", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: neonGreen)),
          ),
        ],
      ),
    );
  }

  // --- EFECTO CRISTAL EN LA NAVBAR ---
  Widget _buildGlassmorphicNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, false, () => Navigator.pop(context)),
              _buildNavItem(Icons.leaderboard_rounded, true, () {}), // Marcado activo

              // ✅ CONECTADO CORRECTAMENTE A SETTINGS
              _buildNavItem(Icons.settings_rounded, false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(idCliente: widget.idUsuarioBarbero),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? neonCyan.withOpacity(0.2) : Colors.transparent, // Resalte cyan para finanzas
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? neonCyan : Colors.white70, size: 26),
      ),
    );
  }
}