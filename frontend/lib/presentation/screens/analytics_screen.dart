import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/analytics_dtos.dart';
import 'package:frontend/domain/repositories/analytics_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsRepository _repository = AnalyticsRepository();
  DashboardStatsDto? _stats;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getGlobalStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.globalAnalytics, style: GoogleFonts.notoSans(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(l10n.mostUsedMedications, Icons.trending_up),
                      const SizedBox(height: 16),
                      _buildChartCard(
                        _stats!.topUsedMedications,
                        const Color.fromARGB(255, 173, 128, 245), // Твій фірмовий фіолетовий
                      ),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionHeader(l10n.mostExpiredORwrittenOff, Icons.delete_outline),
                      const SizedBox(height: 16),
                      _buildChartCard(
                        _stats!.topExpiredMedications,
                        Colors.redAccent.shade200,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(List<MedicationStatDto> data, Color barColor) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Text(l10n.noDataAvailableYet, style: GoogleFonts.notoSans(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Знаходимо максимальне значення для масштабування Y-осі
    double maxY = 0;
    for (var item in data) {
      if (item.totalQuantity > maxY) maxY = item.totalQuantity.toDouble();
    }
    maxY = maxY == 0 ? 10 : maxY * 1.2; // Додаємо 20% простору зверху

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.blueGrey.shade900,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = data[group.x.toInt()];
                    return BarTooltipItem(
                      '${item.medicationName}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${item.totalQuantity} ${item.unit}',
                          style: TextStyle(
                            color: barColor.withOpacity(0.8), // Світліший відтінок для тексту
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        // Скорочуємо назву, якщо довга
                        String name = data[index].medicationName;
                        if (name.length > 8) name = '${name.substring(0, 6)}..';
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(name, style: GoogleFonts.notoSans(fontSize: 10, color: Colors.grey.shade700)),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                       if (value == 0) return const SizedBox.shrink();
                       return Text(value.toInt().toString(), 
                         style: GoogleFonts.notoSans(fontSize: 10, color: Colors.grey.shade500));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true, 
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.totalQuantity.toDouble(),
                      color: barColor,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY, // Фон на повну висоту
                        color: Colors.grey.shade50,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}