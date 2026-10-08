import 'package:flutter/material.dart';
import '../services/water_monitoring_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'charts_screen.dart';
import 'history_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final WaterMonitoringService service;

  const MainNavigationScreen({
    super.key,
    required this.service,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final isAlert = service.isAlertActive;
    final warningCount = service.historyLogs
        .where((element) => element.isWarning)
        .length;

    final screens = [
      DashboardScreen(service: service),
      ChartsScreen(service: service),
      HistoryScreen(service: service),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceNavy,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Dashboard',
                  icon: Icons.speed_rounded,
                  badgeAlert: isAlert,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Smart Charts',
                  icon: Icons.bar_chart_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'History Logs',
                  icon: Icons.history_rounded,
                  badgeCount: warningCount > 0 ? warningCount : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    bool badgeAlert = false,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.oceanPrimary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: AppColors.cyanAccent.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.cyanAccent
                      : AppColors.textMuted,
                ),
                // Alert Dot
                if (badgeAlert)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.statusWarning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // Count Badge
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.statusCaution,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
