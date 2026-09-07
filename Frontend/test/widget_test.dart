import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('WeatherGPT app launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherGPTApp());
    await tester.pumpAndSettle();

    // Verify that WeatherGPT title renders
    expect(find.text('WeatherGPT'), findsWidgets);
  });
}
