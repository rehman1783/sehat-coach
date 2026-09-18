import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/main.dart';

void main() {
  testWidgets('SehatCoach splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SehatCoachApp());
    expect(find.text('SEHAT COACH'), findsOneWidget);
    expect(find.text('START ONBOARDING'), findsOneWidget);
  });
}
