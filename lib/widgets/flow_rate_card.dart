import 'package:flutter/material.dart';
import '../models/flow_data_point.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'water_wave_gauge.dart';

class FlowRateCard extends StatelessWidget {
  final double currentFlowRate;
  final double safeThreshold;
  final double peakFlowRate;
  final bool isAlert;
  final List<FlowDataPoint> recentPoints;

  const FlowRateCard({
    super.key,
    required this.currentFlowRate,
    required this.safeThreshold,
    required this.peakFlowRate,
    required this.isAlert,
    required this.recentPoints,
  });

  @override
  Widget build(BuildContext context) {
    final double flowRatio =
        (currentFlowRate / AppConstants.maxFlowRateDisplay).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardNavy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAlert
              ? AppColors.statusWarning.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.1),
          width: isAlert ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlert
                ? AppColors.statusWarning.withValues(alpha: 0.25)
                : AppColors.oceanPrimary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient wave gauge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: Opacity(
              opacity: 0.35,
              child: WaterWaveGauge(
                percentage: flowRatio,
                isAlert: isAlert,
                height: 90,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row with Live Badge & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isAlert
                                ? AppColors.statusWarning.withValues(alpha: 0.15)
                                : AppColors.oceanPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.speed_rounded,
                            color: isAlert
                                ? AppColors.statusWarning
                                : AppColors.cyanAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT FLOW RATE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              isAlert ? 'High Surge Detected' : 'Real-time Telemetry',
                              style: TextStyle(
                                color: isAlert
                                    ? AppColors.statusWarning
                                    : AppColors.cyanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isAlert
                            ? AppColors.statusWarningBg
                            : AppColors.statusNormalBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAlert
                              ? AppColors.statusWarning.withValues(alpha: 0.5)
                              : AppColors.statusNormal.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAlert
                                  ? AppColors.statusWarning
                                  : AppColors.statusNormal,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAlert ? 'WARNING' : 'NORMAL',
                            style: TextStyle(
                              color: isAlert
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF6EE7B7),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Flow Rate Readout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppFormatters.formatFlow(currentFlowRate),
                      style: TextStyle(
                        color: isAlert ? const Color(0xFFFCA5A5) : Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.flowRateUnit,
                      style: TextStyle(
                        color: isAlert
                            ? AppColors.statusWarning
                            : AppColors.cyanAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Flow Progress Bar against Max and Threshold
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Background Bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Safe Threshold Marker (25 L/m out of 50 max)
                        Positioned(
                          left: (safeThreshold / AppConstants.maxFlowRateDisplay) *
                              (MediaQuery.of(context).size.width - 72),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 2,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        // Active Flow Fill
                        FractionallySizedBox(
                          widthFactor: flowRatio,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: isAlert
                                  ? AppColors.warningGradient
                                  : AppColors.flowGradient,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: (isAlert
                                          ? AppColors.statusWarning
                                          : AppColors.cyanAccent)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '0 L/m',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Safe Limit: ${safeThreshold.toStringAsFixed(1)} L/m',
                          style: TextStyle(
                            color: isAlert
                                ? AppColors.statusWarning
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '50 L/m',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),

                // Sub-stats (Today's Peak & Velocity)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Today\'s Peak: ${AppFormatters.formatFlow(peakFlowRate)} L/m',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          isAlert
                              ? Icons.error_outline_rounded
                              : Icons.check_circle_outline_rounded,
                          color: isAlert
                              ? AppColors.statusWarning
                              : AppColors.statusNormal,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAlert ? 'Threshold Exceeded' : 'Flow Optimal',
                          style: TextStyle(
                            color: isAlert
                                ? AppColors.statusWarning
                                : AppColors.statusNormal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
