import 'package:flutter/material.dart';
import '../services/water_monitoring_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/smart_consumption_chart.dart';

class ChartsScreen extends StatefulWidget {
  final WaterMonitoringService service;

  const ChartsScreen({
    super.key,
    required this.service,
  });

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _tabIndex = 0; // 0 = Hourly (24h), 1 = Daily (7d)

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final isHourly = _tabIndex == 0;
    final data = isHourly ? service.hourlyConsumption : service.dailyConsumption;

    final totalVolume =
        data.fold<double>(0.0, (prev, element) => prev + element.volume);
    final avgVolume = data.isEmpty ? 0.0 : totalVolume / data.length;
    final peakItem = data.isEmpty
        ? null
        : data.reduce((a, b) => a.volume > b.volume ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Consumption Charts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Chart Guide',
            onPressed: () => _showChartInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Period Toggle Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleTab(
                        index: 0,
                        title: 'Past 24 Hours',
                        icon: Icons.schedule_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildToggleTab(
                        index: 1,
                        title: 'Past 7 Days',
                        icon: Icons.calendar_view_week_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Interactive Smart Chart
            SmartConsumptionChart(
              hourlyData: service.hourlyConsumption,
              dailyData: service.dailyConsumption,
              safeThreshold: service.safeFlowThreshold,
            ),

            // Analytics Insight Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      title: 'PEAK INTERVAL',
                      value: peakItem != null ? peakItem.label : '-',
                      subValue: peakItem != null
                          ? '${AppFormatters.formatVolume(peakItem.volume)} L'
                          : '',
                      icon: Icons.bolt_rounded,
                      color: AppColors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInsightCard(
                      title: 'AVERAGE DRAW',
                      value: '${AppFormatters.formatVolume(avgVolume)} L',
                      subValue: isHourly ? 'Per hour' : 'Per day',
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInsightCard(
                      title: 'TOTAL CONSUMED',
                      value: '${AppFormatters.formatVolume(totalVolume)} L',
                      subValue: AppFormatters.formatCubicMeters(totalVolume),
                      icon: Icons.pie_chart_outline_rounded,
                      color: AppColors.oceanPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInsightCard(
                      title: 'FLOW STABILITY',
                      value: '94.2%',
                      subValue: 'Optimal flow rate',
                      icon: Icons.verified_outlined,
                      color: AppColors.statusNormal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Detailed Interval Data Breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isHourly ? 'HOURLY CONSUMPTION LOG' : 'DAILY SUMMARY LOG',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // List of time intervals
            ...data.reversed.map((metric) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardNavy,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: metric.isWarning
                        ? AppColors.statusWarning.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: metric.isWarning
                                ? AppColors.statusWarningBg
                                : AppColors.surfaceNavy,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            metric.isWarning
                                ? Icons.warning_amber_rounded
                                : Icons.water_drop_rounded,
                            size: 14,
                            color: metric.isWarning
                                ? AppColors.statusWarning
                                : AppColors.cyanAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Peak: ${AppFormatters.formatFlow(metric.peakFlow)} L/m',
                              style: TextStyle(
                                color: metric.isWarning
                                    ? const Color(0xFFFCA5A5)
                                    : AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppFormatters.formatVolume(metric.volume)} L',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          metric.isWarning ? 'High Surge' : 'Normal',
                          style: TextStyle(
                            color: metric.isWarning
                                ? AppColors.statusWarning
                                : AppColors.statusNormal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTab({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.oceanPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required String subValue,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subValue.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChartInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'About Consumption Charts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Smart charts track water consumption trends across hours and days. Amber and red bars highlight intervals where flow rate exceeded safe thresholds. Tap on any bar in the chart to inspect volume and peak velocity details.',
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.oceanPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
