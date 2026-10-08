import 'package:flutter/material.dart';
import 'services/water_monitoring_service.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterFlowApp());
}

class WaterFlowApp extends StatefulWidget {
  const WaterFlowApp({super.key});

  @override
  State<WaterFlowApp> createState() => _WaterFlowAppState();
}

class _WaterFlowAppState extends State<WaterFlowApp> {
  late final WaterMonitoringService _monitoringService;

  @override
  void initState() {
    super.initState();
    _monitoringService = WaterMonitoringService();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _monitoringService,
      builder: (context, _) {
        return MaterialApp(
          title: 'HydroFlow - Water Monitoring',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: MainNavigationScreen(service: _monitoringService),
        );
      },
    );
  }
}
