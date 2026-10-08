import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/flow_data_point.dart';
import '../models/alert_model.dart';
import '../models/flow_log_entry.dart';
import '../models/consumption_metric.dart';
import '../utils/constants.dart';

enum SimulationFlowState {
  normal,
  surge,
  idle,
}

class WaterMonitoringService extends ChangeNotifier {
  static final WaterMonitoringService _instance =
      WaterMonitoringService._internal();
  factory WaterMonitoringService() => _instance;

  WaterMonitoringService._internal() {
    _initializeData();
    _startTelemetryTimer();
  }

  final Random _random = Random();
  Timer? _telemetryTimer;

  // Real-time telemetry
  double _currentFlowRate = 16.5; // L/min
  double _totalVolume = 1248.5; // Liters
  double _safeFlowThreshold = AppConstants.defaultSafeFlowThreshold; // 25.0 L/min
  bool _isSimulationRunning = true;
  SimulationFlowState _flowState = SimulationFlowState.normal;

  // Real-time rolling buffer (last 60 seconds)
  final List<FlowDataPoint> _recentDataPoints = [];

  // Active Alert
  FlowAlert? _activeAlert;

  // History Logs
  final List<FlowLogEntry> _historyLogs = [];

  // Aggregated Trends for Charts
  final List<ConsumptionMetric> _hourlyConsumption = [];
  final List<ConsumptionMetric> _dailyConsumption = [];

  // Tracking current active flow session
  DateTime? _sessionStartTime;
  double _sessionVolumeAcc = 0.0;
  double _sessionPeakFlow = 0.0;

  // Stats
  double _todayPeakFlow = 28.4;
  int _alertEventsToday = 3;

  // Getters
  double get currentFlowRate => _currentFlowRate;
  double get totalVolume => _totalVolume;
  double get safeFlowThreshold => _safeFlowThreshold;
  bool get isAlertActive => _currentFlowRate > _safeFlowThreshold;
  FlowAlert? get activeAlert => _activeAlert;
  bool get isSimulationRunning => _isSimulationRunning;
  SimulationFlowState get flowState => _flowState;
  List<FlowDataPoint> get recentDataPoints =>
      List.unmodifiable(_recentDataPoints);
  List<FlowLogEntry> get historyLogs => List.unmodifiable(_historyLogs);
  List<ConsumptionMetric> get hourlyConsumption =>
      List.unmodifiable(_hourlyConsumption);
  List<ConsumptionMetric> get dailyConsumption =>
      List.unmodifiable(_dailyConsumption);
  double get todayPeakFlow => _todayPeakFlow;
  int get alertEventsToday => _alertEventsToday;

  double get todayAverageFlow {
    if (_hourlyConsumption.isEmpty) return 12.0;
    final totalVol = _hourlyConsumption.fold<double>(
        0.0, (prev, element) => prev + element.volume);
    return totalVol / _hourlyConsumption.length;
  }

  // Percentage of daily quota used
  double get dailyQuotaProgress =>
      (_totalVolume % AppConstants.dailyVolumeQuota) /
      AppConstants.dailyVolumeQuota;

  void _initializeData() {
    final now = DateTime.now();

    // 1. Seed rolling buffer (last 30 seconds)
    double seedRate = 15.0;
    for (int i = 30; i >= 0; i--) {
      seedRate += (_random.nextDouble() - 0.5) * 1.5;
      seedRate = seedRate.clamp(12.0, 18.0);
      _recentDataPoints.add(
        FlowDataPoint(
          timestamp: now.subtract(Duration(seconds: i)),
          flowRate: seedRate,
          volumeDelta: seedRate / 60.0,
        ),
      );
    }

    // 2. Seed realistic past 24 hours consumption
    for (int i = 23; i >= 0; i--) {
      final hourTime = now.subtract(Duration(hours: i));
      final hourOfDay = hourTime.hour;
      final label = '${hourOfDay.toString().padLeft(2, '0')}:00';

      // Morning and evening peak hours consume more
      double baseVol;
      if (hourOfDay >= 6 && hourOfDay <= 9) {
        baseVol = 42.0 + _random.nextDouble() * 25.0; // Morning rush
      } else if (hourOfDay >= 18 && hourOfDay <= 21) {
        baseVol = 38.0 + _random.nextDouble() * 28.0; // Evening peak
      } else if (hourOfDay >= 1 && hourOfDay <= 5) {
        baseVol = 1.5 + _random.nextDouble() * 3.0; // Night low
      } else {
        baseVol = 18.0 + _random.nextDouble() * 16.0; // Day regular
      }

      final peakRate = (baseVol * 0.45) + _random.nextDouble() * 4.0;
      final isWarn = peakRate > _safeFlowThreshold;

      _hourlyConsumption.add(
        ConsumptionMetric(
          label: label,
          timestamp: hourTime,
          volume: double.parse(baseVol.toStringAsFixed(1)),
          peakFlow: double.parse(peakRate.toStringAsFixed(1)),
          isWarning: isWarn,
        ),
      );
    }

    // 3. Seed past 7 days consumption
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 6; i >= 0; i--) {
      final dayTime = now.subtract(Duration(days: i));
      final dayName = dayNames[dayTime.weekday - 1];
      final dayVol = 280.0 + _random.nextDouble() * 160.0;
      final peakFlow = 22.0 + _random.nextDouble() * 8.0;
      final isWarn = peakFlow > _safeFlowThreshold;

      _dailyConsumption.add(
        ConsumptionMetric(
          label: dayName,
          timestamp: dayTime,
          volume: double.parse(dayVol.toStringAsFixed(1)),
          peakFlow: double.parse(peakFlow.toStringAsFixed(1)),
          isWarning: isWarn,
        ),
      );
    }

    // 4. Seed history events
    _historyLogs.addAll([
      FlowLogEntry(
        id: 'log-001',
        title: 'Morning High Volume Surge',
        startTime: now.subtract(const Duration(minutes: 42)),
        endTime: now.subtract(const Duration(minutes: 31)),
        duration: const Duration(minutes: 11),
        consumedVolume: 324.5,
        peakFlowRate: 31.8,
        averageFlowRate: 29.5,
        status: LogStatus.warning,
        notes: 'Flow rate exceeded safe threshold limit (25.0 L/m).',
      ),
      FlowLogEntry(
        id: 'log-002',
        title: 'Main Line Supply Cycle',
        startTime: now.subtract(const Duration(hours: 2, minutes: 15)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        duration: const Duration(minutes: 30),
        consumedVolume: 412.0,
        peakFlowRate: 18.4,
        averageFlowRate: 13.7,
        status: LogStatus.normal,
        notes: 'Regular scheduled consumption under safe limits.',
      ),
      FlowLogEntry(
        id: 'log-003',
        title: 'Kitchen & Utility Fixtures',
        startTime: now.subtract(const Duration(hours: 4, minutes: 10)),
        endTime: now.subtract(const Duration(hours: 3, minutes: 58)),
        duration: const Duration(minutes: 12),
        consumedVolume: 145.2,
        peakFlowRate: 15.6,
        averageFlowRate: 12.1,
        status: LogStatus.normal,
        notes: 'Standard flow pattern observed.',
      ),
      FlowLogEntry(
        id: 'log-004',
        title: 'Garden Irrigation Surge',
        startTime: now.subtract(const Duration(hours: 6, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 6, minutes: 05)),
        duration: const Duration(minutes: 25),
        consumedVolume: 690.4,
        peakFlowRate: 28.2,
        averageFlowRate: 27.6,
        status: LogStatus.warning,
        notes: 'Extended high flow rate alert recorded.',
      ),
      FlowLogEntry(
        id: 'log-005',
        title: 'Early Morning Routine',
        startTime: now.subtract(const Duration(hours: 9, minutes: 20)),
        endTime: now.subtract(const Duration(hours: 8, minutes: 50)),
        duration: const Duration(minutes: 30),
        consumedVolume: 298.0,
        peakFlowRate: 17.1,
        averageFlowRate: 9.9,
        status: LogStatus.normal,
        notes: 'Normal morning residential draw.',
      ),
      FlowLogEntry(
        id: 'log-006',
        title: 'Overnight Pressure Anomaly',
        startTime: now.subtract(const Duration(hours: 14, minutes: 10)),
        endTime: now.subtract(const Duration(hours: 14, minutes: 02)),
        duration: const Duration(minutes: 8),
        consumedVolume: 215.8,
        peakFlowRate: 27.0,
        averageFlowRate: 26.9,
        status: LogStatus.warning,
        notes: 'Sudden flow spike during low demand period.',
      ),
    ]);

    _sessionStartTime = now;
    _checkAlertCondition();
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSimulationRunning) return;
      _tickTelemetry();
    });
  }

  void _tickTelemetry() {
    final now = DateTime.now();

    // Calculate dynamic flow rate based on current simulation flow state
    switch (_flowState) {
      case SimulationFlowState.normal:
        // Fluctuates smoothly around 14 - 18 L/min
        final delta = (_random.nextDouble() - 0.5) * 1.8;
        _currentFlowRate = (_currentFlowRate + delta).clamp(11.0, 22.0);
        break;
      case SimulationFlowState.surge:
        // Fluctuates in warning zone: 27 - 36 L/min
        final delta = (_random.nextDouble() - 0.5) * 2.2;
        _currentFlowRate = (_currentFlowRate + delta).clamp(26.5, 38.0);
        break;
      case SimulationFlowState.idle:
        // No flow / negligible
        _currentFlowRate = (_currentFlowRate * 0.7).clamp(0.0, 0.2);
        break;
    }

    // Accumulate volume: (Flow Rate in L/min) / 60 seconds = Volume per second
    final volumeDelta = _currentFlowRate / 60.0;
    _totalVolume += volumeDelta;

    if (_currentFlowRate > _todayPeakFlow) {
      _todayPeakFlow = _currentFlowRate;
    }

    // Update active session tracking
    _sessionVolumeAcc += volumeDelta;
    if (_currentFlowRate > _sessionPeakFlow) {
      _sessionPeakFlow = _currentFlowRate;
    }

    // Update rolling buffer
    _recentDataPoints.add(
      FlowDataPoint(
        timestamp: now,
        flowRate: _currentFlowRate,
        volumeDelta: volumeDelta,
      ),
    );

    // Keep max 60 points (last 1 minute)
    if (_recentDataPoints.length > 60) {
      _recentDataPoints.removeAt(0);
    }

    // Check alert conditions
    _checkAlertCondition();

    notifyListeners();
  }

  void _checkAlertCondition() {
    final now = DateTime.now();
    if (_currentFlowRate > _safeFlowThreshold) {
      if (_activeAlert == null) {
        _alertEventsToday++;
        _activeAlert = FlowAlert(
          id: 'alert-${now.millisecondsSinceEpoch}',
          title: 'High Flow Rate Warning!',
          message:
              'Current flow rate exceeds safe limit (${_safeFlowThreshold.toStringAsFixed(1)} L/m). Inspect fixtures immediately.',
          currentFlowRate: _currentFlowRate,
          threshold: _safeFlowThreshold,
          timestamp: now,
          severity: _currentFlowRate > _safeFlowThreshold * 1.3
              ? FlowAlertSeverity.critical
              : FlowAlertSeverity.warning,
        );
      } else {
        // Update current flow on active alert
        _activeAlert = FlowAlert(
          id: _activeAlert!.id,
          title: _activeAlert!.title,
          message: _activeAlert!.message,
          currentFlowRate: _currentFlowRate,
          threshold: _safeFlowThreshold,
          timestamp: _activeAlert!.timestamp,
          severity: _currentFlowRate > _safeFlowThreshold * 1.3
              ? FlowAlertSeverity.critical
              : FlowAlertSeverity.warning,
        );
      }
    } else {
      // Flow returned to safe zone
      if (_activeAlert != null) {
        // Log the past surge event
        _logCompletedSession(status: LogStatus.warning, isSurge: true);
        _activeAlert = null;
      }
    }
  }

  void _logCompletedSession({
    required LogStatus status,
    bool isSurge = false,
  }) {
    if (_sessionVolumeAcc < 0.5) return; // Ignore micro drips
    final now = DateTime.now();
    final start = _sessionStartTime ?? now.subtract(const Duration(minutes: 1));
    final duration = now.difference(start);

    final avgRate = duration.inSeconds > 0
        ? (_sessionVolumeAcc / (duration.inSeconds / 60.0))
        : _sessionPeakFlow;

    final entry = FlowLogEntry(
      id: 'log-${now.millisecondsSinceEpoch}',
      title: isSurge
          ? 'High Flow Rate Surge Resolved'
          : 'Monitored Flow Cycle',
      startTime: start,
      endTime: now,
      duration: duration.inSeconds < 10 ? const Duration(seconds: 45) : duration,
      consumedVolume: double.parse(_sessionVolumeAcc.toStringAsFixed(1)),
      peakFlowRate: double.parse(_sessionPeakFlow.toStringAsFixed(1)),
      averageFlowRate: double.parse(avgRate.toStringAsFixed(1)),
      status: status,
      notes: isSurge
          ? 'Event automatically captured after exceeding ${_safeFlowThreshold.toStringAsFixed(1)} L/m.'
          : 'Normal consumption session.',
    );

    _historyLogs.insert(0, entry);
    // Reset session trackers
    _sessionStartTime = now;
    _sessionVolumeAcc = 0.0;
    _sessionPeakFlow = _currentFlowRate;
  }

  // --- CONTROLLER METHODS (for testing and user interaction) ---

  /// Set flow state to normal (14-18 L/min)
  void setNormalFlow() {
    _flowState = SimulationFlowState.normal;
    _currentFlowRate = 16.2;
    notifyListeners();
  }

  /// Trigger a flow surge (32.5 L/min) exceeding the safe threshold
  void triggerSurge() {
    _flowState = SimulationFlowState.surge;
    _currentFlowRate = 32.8;
    _checkAlertCondition();
    notifyListeners();
  }

  /// Set flow state to idle (0 L/min)
  void setIdleFlow() {
    if (_sessionVolumeAcc > 1.0) {
      _logCompletedSession(
        status: _sessionPeakFlow > _safeFlowThreshold
            ? LogStatus.warning
            : LogStatus.normal,
      );
    }
    _flowState = SimulationFlowState.idle;
    _currentFlowRate = 0.0;
    _checkAlertCondition();
    notifyListeners();
  }

  /// Update the safe maximum limit threshold
  void updateSafeThreshold(double newThreshold) {
    _safeFlowThreshold = newThreshold;
    _checkAlertCondition();
    notifyListeners();
  }

  /// Toggle play/pause on live simulation
  void toggleSimulation() {
    _isSimulationRunning = !_isSimulationRunning;
    notifyListeners();
  }

  /// Reset accumulated total volume to zero
  void resetTotalVolume() {
    _totalVolume = 0.0;
    notifyListeners();
  }

  /// Clear history logs
  void clearLogs() {
    _historyLogs.clear();
    notifyListeners();
  }

  /// Manually dismiss current active alert banner
  void dismissAlert() {
    _activeAlert = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
