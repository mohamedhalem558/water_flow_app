import 'package:flutter/material.dart';
import '../services/water_monitoring_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/alert_banner.dart';
import '../widgets/flow_rate_card.dart';
import '../widgets/total_volume_card.dart';
import '../widgets/flow_stat_card.dart';
import '../widgets/smart_consumption_chart.dart';
import '../widgets/simulation_controller.dart';

class DashboardScreen extends StatelessWidget {
  final WaterMonitoringService service;

  const DashboardScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final alert = service.activeAlert;
    final isAlertActive = service.isAlertActive;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.flowGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.oceanPrimary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.water_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Live Connection / Stream Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: service.isSimulationRunning
                            ? AppColors.surfaceNavy
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: service.isSimulationRunning
                              ? AppColors.cyanAccent.withValues(alpha: 0.3)
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: service.isSimulationRunning
                                  ? AppColors.cyanAccent
                                  : Colors.orange,
                              boxShadow: service.isSimulationRunning
                                  ? [
                                      BoxShadow(
                                        color: AppColors.cyanAccent
                                            .withValues(alpha: 0.8),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.isSimulationRunning ? 'LIVE DATA' : 'PAUSED',
                            style: TextStyle(
                              color: service.isSimulationRunning
                                  ? Colors.white
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prominent Alert Banner if flow rate exceeds safe limit
            if (isAlertActive && alert != null)
              SliverToBoxAdapter(
                child: AlertBanner(
                  alert: alert,
                  onDismiss: service.dismissAlert,
                ),
              ),

            // Core Feature: Real-time Flow Rate Card
            SliverToBoxAdapter(
              child: FlowRateCard(
                currentFlowRate: service.currentFlowRate,
                safeThreshold: service.safeFlowThreshold,
                peakFlowRate: service.todayPeakFlow,
                isAlert: isAlertActive,
                recentPoints: service.recentDataPoints,
              ),
            ),

            // Core Feature: Real-time Total Volume Card
            SliverToBoxAdapter(
              child: TotalVolumeCard(
                totalVolume: service.totalVolume,
                dailyQuotaProgress: service.dailyQuotaProgress,
                onReset: () => _confirmResetVolume(context),
              ),
            ),

            // Telemetry Quick Stats Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FlowStatCard(
                        title: 'Today Peak',
                        value: AppFormatters.formatFlow(service.todayPeakFlow),
                        unit: AppConstants.flowRateUnit,
                        icon: Icons.trending_up_rounded,
                        accentColor: AppColors.cyanAccent,
                        subtitle: 'Recorded maximum',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FlowStatCard(
                        title: 'Alert Events',
                        value: '${service.alertEventsToday}',
                        unit: 'events',
                        icon: Icons.warning_amber_rounded,
                        accentColor: service.alertEventsToday > 0
                            ? AppColors.statusCaution
                            : AppColors.statusNormal,
                        subtitle: 'Threshold breaches',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Consumption Trends Chart Section
            SliverToBoxAdapter(
              child: SmartConsumptionChart(
                hourlyData: service.hourlyConsumption,
                dailyData: service.dailyConsumption,
                safeThreshold: service.safeFlowThreshold,
              ),
            ),

            // Testing and Simulation Control Toolbar
            SliverToBoxAdapter(
              child: SimulationController(service: service),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetVolume(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Volume Meter?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will reset the accumulated volume counter back to 0.0 Liters. History logs will be preserved.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.oceanPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              service.resetTotalVolume();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
