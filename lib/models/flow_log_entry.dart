enum LogStatus {
  normal,
  warning,
}

class FlowLogEntry {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final double consumedVolume; // in Liters
  final double peakFlowRate; // in L/min
  final double averageFlowRate; // in L/min
  final LogStatus status;
  final String? notes;

  const FlowLogEntry({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.consumedVolume,
    required this.peakFlowRate,
    required this.averageFlowRate,
    required this.status,
    this.notes,
  });

  bool get isWarning => status == LogStatus.warning;
}
