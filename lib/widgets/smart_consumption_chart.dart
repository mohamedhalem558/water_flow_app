import 'dart:math';
import 'package:flutter/material.dart';
import '../models/consumption_metric.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

enum ChartTimeframe {
  hourly,
  daily,
}

class SmartConsumptionChart extends StatefulWidget {
  final List<ConsumptionMetric> hourlyData;
  final List<ConsumptionMetric> dailyData;
  final double safeThreshold;

  const SmartConsumptionChart({
    super.key,
    required this.hourlyData,
    required this.dailyData,
    required this.safeThreshold,
  });

  @override
  State<SmartConsumptionChart> createState() => _SmartConsumptionChartState();
}

class _SmartConsumptionChartState extends State<SmartConsumptionChart> {
  ChartTimeframe _selectedTimeframe = ChartTimeframe.hourly;
  int? _selectedIndex;

  List<ConsumptionMetric> get _currentData {
    if (_selectedTimeframe == ChartTimeframe.hourly) {
      // Show the most recent 12 hours for clean legible mobile view
      return widget.hourlyData.length > 12
          ? widget.hourlyData.sublist(widget.hourlyData.length - 12)
          : widget.hourlyData;
    } else {
      return widget.dailyData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;
    final maxVolume = data.isEmpty
        ? 100.0
        : data.map((e) => e.volume).reduce(max) * 1.15;

    final selectedMetric = (_selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < data.length)
        ? data[_selectedIndex!]
        : null;

    final totalVolume =
        data.fold<double>(0.0, (prev, element) => prev + element.volume);
    final avgVolume = data.isEmpty ? 0.0 : totalVolume / data.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONSUMPTION TRENDS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedTimeframe == ChartTimeframe.hourly
                        ? 'Hourly Draw (Liters)'
                        : 'Daily Volume (Liters)',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              // Timeframe Segmented Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTimeframeTab('Hourly', ChartTimeframe.hourly),
                    const SizedBox(width: 4),
                    _buildTimeframeTab('Daily', ChartTimeframe.daily),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Selected Data Point Tooltip Callout
          if (selectedMetric != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: selectedMetric.isWarning
                    ? AppColors.statusWarningBg
                    : AppColors.surfaceNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedMetric.isWarning
                      ? AppColors.statusWarning
                      : AppColors.cyanAccent.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedMetric.isWarning
                            ? Icons.warning_rounded
                            : Icons.touch_app_rounded,
                        color: selectedMetric.isWarning
                            ? AppColors.statusWarning
                            : AppColors.cyanAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedMetric.label}: ${AppFormatters.formatVolume(selectedMetric.volume)} L',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Peak: ${AppFormatters.formatFlow(selectedMetric.peakFlow)} L/m',
                    style: TextStyle(
                      color: selectedMetric.isWarning
                          ? const Color(0xFFFCA5A5)
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Chart Canvas
          SizedBox(
            height: 190,
            child: GestureDetector(
              onTapDown: (details) {
                _handleTouch(details.localPosition, data.length);
              },
              onPanUpdate: (details) {
                _handleTouch(details.localPosition, data.length);
              },
              child: CustomPaint(
                size: const Size(double.infinity, 190),
                painter: _BarChartPainter(
                  data: data,
                  maxVolume: maxVolume,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Summary Stats Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterStat(
                'Total in View',
                '${AppFormatters.formatVolume(totalVolume)} L',
                AppColors.cyanAccent,
              ),
              _buildFooterStat(
                'Average Draw',
                '${AppFormatters.formatVolume(avgVolume)} L',
                AppColors.textLight,
              ),
              _buildFooterStat(
                'Peak Interval',
                data.isEmpty
                    ? '-'
                    : '${data.reduce((a, b) => a.volume > b.volume ? a : b).label}',
                AppColors.statusNormal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTouch(Offset localPosition, int dataCount) {
    if (dataCount == 0) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final double width = box.size.width - 72; // Adjusted for padding
    final double barSlotWidth = width / dataCount;
    final int index = (localPosition.dx / barSlotWidth).floor();

    if (index >= 0 && index < dataCount) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildTimeframeTab(String label, ChartTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = timeframe;
          _selectedIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.oceanPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ConsumptionMetric> data;
  final double maxVolume;
  final int? selectedIndex;

  _BarChartPainter({
    required this.data,
    required this.maxVolume,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double bottomLabelHeight = 24.0;
    final double chartHeight = size.height - bottomLabelHeight;
    final double slotWidth = size.width / data.length;
    final double barWidth = (slotWidth * 0.55).clamp(8.0, 24.0);

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double normalizedHeight =
          (item.volume / (maxVolume > 0 ? maxVolume : 1.0)).clamp(0.04, 1.0);
      final double barHeight = chartHeight * normalizedHeight;
      final double x = (i * slotWidth) + (slotWidth - barWidth) / 2;
      final double y = chartHeight - barHeight;

      final isSelected = selectedIndex == i;
      final isWarning = item.isWarning;

      // Bar Rect
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
        bottomLeft: const Radius.circular(2),
        bottomRight: const Radius.circular(2),
      );

      // Bar Paint Shader
      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: isWarning
              ? [
                  const Color(0xFFEF4444),
                  const Color(0xFFF97316),
                ]
              : isSelected
                  ? [
                      const Color(0xFF38BDF8),
                      const Color(0xFF0284C7),
                    ]
                  : [
                      const Color(0xFF0284C7).withValues(alpha: 0.85),
                      const Color(0xFF0369A1).withValues(alpha: 0.6),
                    ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(rect, barPaint);

      // Top glowing cap on bar
      final capPaint = Paint()
        ..color = isWarning
            ? Colors.redAccent
            : isSelected
                ? Colors.cyanAccent
                : const Color(0xFF38BDF8)
        ..strokeWidth = 2.0;

      canvas.drawLine(
        Offset(x + 2, y),
        Offset(x + barWidth - 2, y),
        capPaint,
      );

      // Selection outline indicator
      if (isSelected) {
        final outlinePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawRRect(rect, outlinePaint);
      }

      // X-Axis Labels
      final textSpan = TextSpan(
        text: item.label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : isWarning
                  ? const Color(0xFFFCA5A5)
                  : AppColors.textMuted,
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          chartHeight + 6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.maxVolume != maxVolume;
  }
}
