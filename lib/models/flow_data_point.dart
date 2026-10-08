/// Represents an instantaneous water flow data point
class FlowDataPoint {
  final DateTime timestamp;
  final double flowRate; // in Liters per minute (L/min)
  final double volumeDelta; // Liters accumulated since previous sample

  const FlowDataPoint({
    required this.timestamp,
    required this.flowRate,
    this.volumeDelta = 0.0,
  });

  @override
  String toString() =>
      'FlowDataPoint(time: $timestamp, rate: ${flowRate.toStringAsFixed(2)} L/m)';
}
