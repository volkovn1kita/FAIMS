import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/analytics_dtos.dart';
import 'package:frontend/domain/repositories/analytics_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/core/app_theme.dart';

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
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        title: Text(
          l10n.globalAnalytics,
          style: TextStyle(
            fontSize: 22,
            color: Colors.black87, 
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0).copyWith(bottom: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              title: l10n.mostUsedMedications,
                              icon: Icons.trending_up_rounded,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(height: 16),
                            _buildChartCard(
                              data: _stats!.topUsedMedications,
                              baseColor: AppTheme.primary,
                              gradientColors: [
                                AppTheme.primaryLight,
                                AppTheme.primaryDark,
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            _buildSectionHeader(
                              title: l10n.mostExpiredORwrittenOff,
                              icon: Icons.delete_outline_rounded,
                              color: Colors.redAccent.shade400,
                            ),
                            const SizedBox(height: 16),
                            _buildChartCard(
                              data: _stats!.topExpiredMedications,
                              baseColor: Colors.redAccent,
                              gradientColors: [
                                Colors.redAccent.shade200,
                                Colors.redAccent.shade700,
                              ],
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required List<MedicationStatDto> data,
    required Color baseColor,
    required List<Color> gradientColors,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    if (data.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDataAvailableYet,
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    double maxY = 0;
    for (var item in data) {
      if (item.totalQuantity > maxY) maxY = item.totalQuantity.toDouble();
    }
    maxY = maxY == 0 ? 10 : maxY * 1.3; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 24, 20),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = data[group.x.toInt()];
                  return BarTooltipItem(
                    '${item.medicationName}\n',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${item.totalQuantity} ${item.unit}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
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
                  reservedSize: 36,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      String name = data[index].medicationName;
                      if (name.length > 8) name = '${name.substring(0, 6)}..';
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            name,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
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
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value == maxY) return const SizedBox.shrink();
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                      ),
                    );
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
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade100,
                strokeWidth: 1.5,
                dashArray: [5, 5], 
              ),
            ),
            barGroups: data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.totalQuantity.toDouble(),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 20,
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.grey.shade50,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}