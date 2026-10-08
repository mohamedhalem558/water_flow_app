import 'package:flutter_test/flutter_test.dart';
import 'package:water_flow_app/main.dart';

void main() {
  testWidgets('Water Flow App dashboard and navigation smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WaterFlowApp());
    await tester.pump();

    // Verify Dashboard displays Core Telemetry Cards
    expect(find.text('CURRENT FLOW RATE'), findsOneWidget);
    expect(find.text('ACCUMULATED VOLUME'), findsOneWidget);

    // Verify Navigation Tabs exist
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Smart Charts'), findsOneWidget);
    expect(find.text('History Logs'), findsOneWidget);

    // Tap on 'Smart Charts' tab and trigger a frame.
    await tester.tap(find.text('Smart Charts'));
    await tester.pumpAndSettle();

    expect(find.text('Smart Consumption Charts'), findsOneWidget);

    // Tap on 'History Logs' tab and trigger a frame.
    await tester.tap(find.text('History Logs'));
    await tester.pumpAndSettle();

    expect(find.text('Water Flow History & Logs'), findsOneWidget);
  });
}
