enum FlowAlertSeverity {
  info,
  warning,
  critical,
}

class FlowAlert {
  final String id;
  final String title;
  final String message;
  final double currentFlowRate;
  final double threshold;
  final DateTime timestamp;
  final FlowAlertSeverity severity;

  const FlowAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.currentFlowRate,
    required this.threshold,
    required this.timestamp,
    this.severity = FlowAlertSeverity.warning,
  });

  double get exceededBy => currentFlowRate - threshold;
  double get exceededPercentage =>
      threshold > 0 ? ((currentFlowRate - threshold) / threshold) * 100 : 0.0;
}
