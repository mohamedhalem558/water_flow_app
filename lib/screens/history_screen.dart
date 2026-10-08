import 'package:flutter/material.dart';
import '../models/flow_log_entry.dart';
import '../services/water_monitoring_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/log_entry_tile.dart';

enum HistoryFilter {
  all,
  warningOnly,
  normalOnly,
}

class HistoryScreen extends StatefulWidget {
  final WaterMonitoringService service;

  const HistoryScreen({
    super.key,
    required this.service,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryFilter _selectedFilter = HistoryFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FlowLogEntry> get _filteredLogs {
    final logs = widget.service.historyLogs;
    return logs.where((entry) {
      // 1. Filter status
      if (_selectedFilter == HistoryFilter.warningOnly &&
          entry.status != LogStatus.warning) {
        return false;
      }
      if (_selectedFilter == HistoryFilter.normalOnly &&
          entry.status != LogStatus.normal) {
        return false;
      }
      // 2. Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = entry.title.toLowerCase().contains(query);
        final matchesNotes =
            entry.notes?.toLowerCase().contains(query) ?? false;
        return matchesTitle || matchesNotes;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;
    final allLogs = widget.service.historyLogs;

    final warningCount =
        allLogs.where((l) => l.status == LogStatus.warning).length;
    final totalLoggedVolume = allLogs.fold<double>(
        0.0, (prev, element) => prev + element.consumedVolume);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Flow History & Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear History Logs',
            onPressed: allLogs.isEmpty ? null : () => _confirmClearLogs(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Cards Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCardDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat(
                      'TOTAL EVENTS',
                      '${allLogs.length}',
                      Colors.white,
                    ),
                    Container(height: 30, width: 1, color: Colors.white12),
                    _buildSummaryStat(
                      'VOLUME LOGGED',
                      '${AppFormatters.formatVolume(totalLoggedVolume)} L',
                      AppColors.cyanAccent,
                    ),
                    Container(height: 30, width: 1, color: Colors.white12),
                    _buildSummaryStat(
                      'WARNINGS',
                      '$warningCount',
                      warningCount > 0
                          ? AppColors.statusWarning
                          : AppColors.statusNormal,
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search flow events or notes...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardNavy,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.cyanAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All (${allLogs.length})',
                    filter: HistoryFilter.all,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Warnings ($warningCount)',
                    filter: HistoryFilter.warningOnly,
                    highlightColor: AppColors.statusWarning,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Normal (${allLogs.length - warningCount})',
                    filter: HistoryFilter.normalOnly,
                    highlightColor: AppColors.statusNormal,
                  ),
                ],
              ),
            ),

            // History Log List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 4),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        return LogEntryTile(entry: entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required HistoryFilter filter,
    Color? highlightColor,
  }) {
    final isSelected = _selectedFilter == filter;
    final color = highlightColor ?? AppColors.oceanPrimary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.25) : AppColors.cardNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: AppColors.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Events Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No water flow history events matched your current search or status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear All History Logs?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete all historical water flow logs? This action cannot be undone.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusWarning,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.service.clearLogs();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
