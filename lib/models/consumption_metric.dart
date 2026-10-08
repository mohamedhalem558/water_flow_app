class ConsumptionMetric {
  final String label; // "14:00", "Mon", "Oct 08"
  final DateTime timestamp;
  final double volume; // Liters
  final double peakFlow; // L/min
  final bool isWarning;

  const ConsumptionMetric({
    required this.label,
    required this.timestamp,
    required this.volume,
    required this.peakFlow,
    this.isWarning = false,
  });
}
