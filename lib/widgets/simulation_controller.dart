import 'package:flutter/material.dart';
import '../services/water_monitoring_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class SimulationController extends StatelessWidget {
  final WaterMonitoringService service;

  const SimulationController({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final isSurge = service.flowState == SimulationFlowState.surge;
    final isNormal = service.flowState == SimulationFlowState.normal;
    final isIdle = service.flowState == SimulationFlowState.idle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppColors.cyanAccent,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TELEMETRY SIMULATOR & TESTING',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Play / Pause stream toggle
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  service.isSimulationRunning
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  color: service.isSimulationRunning
                      ? AppColors.cyanAccent
                      : AppColors.textMuted,
                ),
                tooltip: service.isSimulationRunning
                    ? 'Pause Telemetry'
                    : 'Resume Telemetry',
                onPressed: service.toggleSimulation,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Test real-time dashboard behavior, warning alerts, and volume accumulation:',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Flow Presets Buttons Row
          Row(
            children: [
              Expanded(
                child: _buildPresetButton(
                  label: 'Normal Flow',
                  sub: '~16 L/m',
                  isActive: isNormal,
                  activeColor: AppColors.oceanPrimary,
                  icon: Icons.water_rounded,
                  onTap: service.setNormalFlow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  label: 'Surge Alert',
                  sub: '>25 L/m',
                  isActive: isSurge,
                  activeColor: AppColors.statusWarning,
                  icon: Icons.warning_rounded,
                  onTap: service.triggerSurge,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetButton(
                  label: 'Zero Flow',
                  sub: '0.0 L/m',
                  isActive: isIdle,
                  activeColor: Colors.grey,
                  icon: Icons.pause_rounded,
                  onTap: service.setIdleFlow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Threshold Adjustment Slider
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Safe Limit: ${service.safeFlowThreshold.toStringAsFixed(0)} L/m',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.cyanAccent,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: AppColors.cyanAccent,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: service.safeFlowThreshold,
                    min: 10.0,
                    max: 40.0,
                    divisions: 30,
                    onChanged: (val) {
                      service.updateSafeThreshold(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton({
    required String label,
    required String sub,
    required bool isActive,
    required Color activeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor : Colors.white.withValues(alpha: 0.08),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            Text(
              sub,
              style: TextStyle(
                color: isActive ? activeColor : AppColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
