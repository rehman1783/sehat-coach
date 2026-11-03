import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/location_data.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/steps/step3_location_step.dart';

void main() {
  testWidgets('city field filters launch cities as the user types', (
    tester,
  ) async {
    String selectedCity = 'Lahore';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Step3LocationStep(
            selectedCountry: LocationRepository.pakistan.name,
            selectedCity: selectedCity,
            language: AppLanguage.english,
            onSelectCountry: (_) {},
            onSelectCity: (city) => selectedCity = city,
            onContinue: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Guj');
    await tester.pump();

    expect(find.text('Gujranwala'), findsOneWidget);
    await tester.tap(find.text('Gujranwala'));
    expect(selectedCity, 'Gujranwala');
  });

  testWidgets('location and city search remain usable at 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String selectedCity = 'Lahore';

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: Step3LocationStep(
              selectedCountry: LocationRepository.pakistan.name,
              selectedCity: selectedCity,
              language: AppLanguage.english,
              onSelectCountry: (_) {},
              onSelectCity: (city) => selectedCity = city,
              onContinue: () {},
            ),
          ),
        ),
      ),
    );

    final searchAll = find.textContaining('Search All');
    await tester.scrollUntilVisible(
      searchAll,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(searchAll);
    await tester.pumpAndSettle();

    expect(find.textContaining('Cities in'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final sheetSearch = find.widgetWithText(TextField, 'Search city...');
    await tester.enterText(sheetSearch, 'Guj');
    await tester.pump();
    expect(find.text('Gujranwala'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Gujranwala'));
    await tester.pumpAndSettle();
    expect(selectedCity, 'Gujranwala');

    final continueButton = find.text('CONTINUE');
    await tester.scrollUntilVisible(
      continueButton,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(continueButton, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
