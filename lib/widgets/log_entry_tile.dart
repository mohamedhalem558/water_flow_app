import 'package:flutter/material.dart';
import '../models/flow_log_entry.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class LogEntryTile extends StatelessWidget {
  final FlowLogEntry entry;
  final VoidCallback? onTap;

  const LogEntryTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = entry.status == LogStatus.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? AppColors.statusWarning.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => _showLogDetails(context, entry),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Status Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Tag Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isWarning
                            ? AppColors.statusWarningBg
                            : AppColors.statusNormalBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isWarning
                              ? AppColors.statusWarning.withValues(alpha: 0.6)
                              : AppColors.statusNormal.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isWarning
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded,
                            size: 12,
                            color: isWarning
                                ? AppColors.statusWarning
                                : AppColors.statusNormal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isWarning ? 'WARNING' : 'NORMAL',
                            style: TextStyle(
                              color: isWarning
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF6EE7B7),
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

                const SizedBox(height: 10),

                // Middle Row: Consumed Volume & Peak Flow
                Row(
                  children: [
                    // Volume
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.cyanAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${AppFormatters.formatVolume(entry.consumedVolume)} ${AppConstants.volumeUnit}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Peak Flow
                    Row(
                      children: [
                        const Icon(
                          Icons.speed_outlined,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Peak: ${AppFormatters.formatFlow(entry.peakFlowRate)} L/m',
                          style: TextStyle(
                            color: isWarning
                                ? const Color(0xFFFCA5A5)
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Duration
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.formatDuration(entry.duration),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom Row: Timestamp & Notes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppFormatters.formatDateTime(entry.startTime),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, FlowLogEntry entry) {
    final isWarning = entry.status == LogStatus.warning;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isWarning
                          ? AppColors.statusWarningBg
                          : AppColors.statusNormalBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isWarning ? 'WARNING' : 'NORMAL',
                      style: TextStyle(
                        color: isWarning
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFF6EE7B7),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.formatDateTime(entry.startTime),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Total Volume Metered',
                '${AppFormatters.formatVolume(entry.consumedVolume)} Liters (${AppFormatters.formatCubicMeters(entry.consumedVolume)})',
              ),
              _buildDetailRow(
                'Peak Flow Velocity',
                '${AppFormatters.formatFlow(entry.peakFlowRate)} L/min',
              ),
              _buildDetailRow(
                'Average Flow Velocity',
                '${AppFormatters.formatFlow(entry.averageFlowRate)} L/min',
              ),
              _buildDetailRow(
                'Event Duration',
                AppFormatters.formatDuration(entry.duration),
              ),
              if (entry.notes != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Event Notes', entry.notes!),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
