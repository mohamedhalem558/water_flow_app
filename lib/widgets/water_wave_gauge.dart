import 'dart:math';
import 'package:flutter/material.dart';

class WaterWaveGauge extends StatefulWidget {
  final double percentage; // 0.0 to 1.0 (fill level)
  final bool isAlert;
  final double height;

  const WaterWaveGauge({
    super.key,
    required this.percentage,
    this.isAlert = false,
    this.height = 100,
  });

  @override
  State<WaterWaveGauge> createState() => _WaterWaveGaugeState();
}

class _WaterWaveGaugeState extends State<WaterWaveGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: _WavePainter(
                wavePhase: _waveController.value * 2 * pi,
                fillPercentage: widget.percentage.clamp(0.05, 0.95),
                isAlert: widget.isAlert,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillPercentage;
  final bool isAlert;

  _WavePainter({
    required this.wavePhase,
    required this.fillPercentage,
    required this.isAlert,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double waterLevel = size.height * (1.0 - fillPercentage);
    final double waveAmplitude = 6.0;

    // Background Wave (slightly lagging phase, lower opacity)
    final backPath = Path();
    backPath.moveTo(0, size.height);
    backPath.lineTo(0, waterLevel);

    for (double x = 0; x <= size.width; x += 1) {
      final y = waterLevel +
          sin((x / size.width * 2 * pi) + wavePhase + 1.2) * (waveAmplitude * 0.7);
      backPath.lineTo(x, y);
    }
    backPath.lineTo(size.width, size.height);
    backPath.close();

    final backPaint = Paint()
      ..shader = LinearGradient(
        colors: isAlert
            ? [
                Colors.red.withValues(alpha: 0.2),
                Colors.orange.withValues(alpha: 0.35),
              ]
            : [
                const Color(0xFF0284C7).withValues(alpha: 0.25),
                const Color(0xFF38BDF8).withValues(alpha: 0.35),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(backPath, backPaint);

    // Foreground Wave
    final frontPath = Path();
    frontPath.moveTo(0, size.height);
    frontPath.lineTo(0, waterLevel);

    for (double x = 0; x <= size.width; x += 1) {
      final y = waterLevel +
          sin((x / size.width * 2 * pi) + wavePhase) * waveAmplitude;
      frontPath.lineTo(x, y);
    }
    frontPath.lineTo(size.width, size.height);
    frontPath.close();

    final frontPaint = Paint()
      ..shader = LinearGradient(
        colors: isAlert
            ? [
                const Color(0xFFEF4444).withValues(alpha: 0.7),
                const Color(0xFF991B1B).withValues(alpha: 0.85),
              ]
            : [
                const Color(0xFF06B6D4).withValues(alpha: 0.6),
                const Color(0xFF0284C7).withValues(alpha: 0.8),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(frontPath, frontPaint);

    // Glowing wave crest highlight line
    final crestPath = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final y = waterLevel +
          sin((x / size.width * 2 * pi) + wavePhase) * waveAmplitude;
      if (x == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }

    final crestPaint = Paint()
      ..color = isAlert
          ? Colors.white.withValues(alpha: 0.7)
          : Colors.cyanAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.isAlert != isAlert;
  }
}
