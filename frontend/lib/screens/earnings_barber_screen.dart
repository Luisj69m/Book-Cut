import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class EarningsBarberScreen extends StatefulWidget {
  const EarningsBarberScreen({super.key});

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

  final mainColor = const Color(0xFF381483);
  final accentColor = const Color(0xFFE96D71);
  final accentBlue = const Color(0xFF2962FF);

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

      setState(() {
        _totalIngresos = (datos['totalIngresos'] ?? 0.0).toDouble();
        _citasDetalle = citas;
        _ingresosPorMes = porMes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white,
                          child: Icon(Icons.content_cut, color: mainColor, size: 36),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text("Panel de ingresos", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(height: 20),

              // ── TARJETA PRINCIPAL ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      children: [
                        // ── CABECERA DEGRADADA ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF381483), Color(0xFF2962FF)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
                                ),
                                child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Ingresos totales", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    SizedBox(height: 4),
                                    Text("Citas cobradas directamente", style: TextStyle(color: Colors.white60, fontSize: 12)),
                                  ],
                                ),
                              ),
                              _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                                  : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade300, width: 1),
                                ),
                                child: Text(
                                  "${_totalIngresos.toStringAsFixed(2).replaceAll('.', ',')} €",
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── CONTENIDO SCROLLABLE ──
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : RefreshIndicator(
                            onRefresh: _cargarDatosFacturacion,
                            color: mainColor,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // ── GRÁFICO DE BARRAS ──
                                if (_ingresosPorMes.isNotEmpty) ...[
                                  _buildGrafico(),
                                  const SizedBox(height: 20),
                                ],

                                // ── TÍTULO LISTA ──
                                Row(
                                  children: [
                                    Container(
                                      width: 4, height: 18,
                                      decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(2)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text("Detalle de citas", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // ── LISTA DE CITAS ──
                                if (_citasDetalle.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40),
                                    child: Column(
                                      children: [
                                        Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade300),
                                        const SizedBox(height: 12),
                                        Text("Aún no hay citas cobradas", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
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

              const SizedBox(height: 12),

              // ── NAV BAR ──
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home_rounded, onTap: () => Navigator.pop(context)),
                      _buildNavItem(Icons.leaderboard_rounded, active: true, onTap: () {}),
                      _buildNavItem(Icons.settings_rounded, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrafico() {
    // Solo mostramos los meses que tienen datos
    final mesesConDatos = _ingresosPorMes.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxY = mesesConDatos.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: accentBlue.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 10),
              const Text("Ingresos por mes", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.25, // margen superior
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => mainColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final mes = mesesConDatos[groupIndex].key;
                      return BarTooltipItem(
                        "${_meses[mes]}\n",
                        const TextStyle(color: Colors.white60, fontSize: 11),
                        children: [
                          TextSpan(
                            text: "${rod.toY.toStringAsFixed(2).replaceAll('.', ',')} €",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_meses[mes], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
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
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(mesesConDatos.length, (index) {
                  final entry = mesesConDatos[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [accentBlue, mainColor],
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

  Widget _buildIngresoCard(String servicio, String precio, String hora, String fecha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: mainColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.content_cut_rounded, color: mainColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(servicio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (fecha.isNotEmpty) ...[
                      Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(fecha, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      const SizedBox(width: 8),
                    ],
                    Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(hora, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Text("+ $precio", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.green.shade800)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.18) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }
}