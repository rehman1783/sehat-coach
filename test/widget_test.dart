import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/main.dart';

void main() {
  testWidgets('SehatCoach app smoke test', (WidgetTester tester) async {
    // Build SehatCoachApp and trigger a frame.
    await tester.pumpWidget(const SehatCoachApp());

    // Verify app title loads.
    expect(find.text('Welcome to SehatCoach'), findsOneWidget);
  });
}
