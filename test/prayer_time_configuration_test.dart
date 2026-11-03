import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/fasting/domain/fasting_schedule.dart';
import 'package:sehat_coach/features/fasting/domain/prayer_time_configuration.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';

void main() {
  final method = PrayerCalculationMethod(
    id: 'reviewed-method',
    displayName: 'Reviewed method',
    parameterVersion: 'fixture-v1',
    reviewApproved: true,
  );

  test('verified city coordinates retain their provenance', () {
    final coordinates = PrayerCoordinates.fromVerifiedCity(
      CityConfigurationEntry(
        cityId: 'fixture-city',
        displayName: 'Fixture City',
        sortOrder: 1,
        latitude: 31.5,
        longitude: 74.3,
      ),
    );

    expect(coordinates.source, PrayerCoordinateSource.selectedCity);
    expect(coordinates.cityId, 'fixture-city');
  });

  test('Other city and incomplete coordinates cannot imply a location', () {
    expect(
      () => CityConfigurationEntry(
        cityId: 'broken',
        displayName: 'Broken',
        sortOrder: 1,
        latitude: 31.5,
      ),
      throwsArgumentError,
    );
    expect(
      () => PrayerCoordinates.fromVerifiedCity(
        CityConfigurationEntry(
          cityId: 'other',
          displayName: 'Other city',
          sortOrder: 2,
          isOther: true,
        ),
      ),
      throwsStateError,
    );
  });

  test(
    'reviewed fixture-verified result creates adjusted fasting window',
    () async {
      final window =
          await CreatePrayerFastingWindow(_Calculator(fixturesPassed: true))
              .execute(
                request: _request(method),
                adjustments: PrayerMinuteAdjustments(
                  fajrMinutes: -2,
                  maghribMinutes: 3,
                ),
              );

      expect(window.startsAtUtc, DateTime.utc(2026, 3, 1, 0, 58));
      expect(window.endsAtUtc, DateTime.utc(2026, 3, 1, 13, 3));
      expect(window.source, FastingTimeSource.verifiedPrayerCalculation);
    },
  );

  test(
    'unreviewed method or failed fixtures cannot activate a window',
    () async {
      final unreviewed = PrayerCalculationMethod(
        id: 'draft',
        displayName: 'Draft',
        parameterVersion: 'v1',
        reviewApproved: false,
      );
      await expectLater(
        CreatePrayerFastingWindow(_Calculator(fixturesPassed: true))
            .execute(request: _request(unreviewed)),
        throwsA(isA<UnverifiedPrayerCalculation>()),
      );
      await expectLater(
        CreatePrayerFastingWindow(_Calculator(fixturesPassed: false))
            .execute(request: _request(method)),
        throwsA(isA<UnverifiedPrayerCalculation>()),
      );
    },
  );

  test('manual adjustments are bounded', () {
    expect(
      () => PrayerMinuteAdjustments(fajrMinutes: 121),
      throwsArgumentError,
    );
  });
}

PrayerTimeRequest _request(PrayerCalculationMethod method) => PrayerTimeRequest(
  localDate: DateTime(2026, 3, 1),
  timezoneOffsetMinutes: 300,
  coordinates: PrayerCoordinates(
    latitude: 31.5,
    longitude: 74.3,
    source: PrayerCoordinateSource.selectedCity,
    cityId: 'fixture-city',
  ),
  method: method,
);

class _Calculator implements PrayerTimeCalculator {
  _Calculator({required this.fixturesPassed});
  final bool fixturesPassed;

  @override
  Future<CalculatedPrayerTimes> calculate(PrayerTimeRequest request) async =>
      CalculatedPrayerTimes(
        fajrUtc: DateTime.utc(2026, 3, 1, 1),
        maghribUtc: DateTime.utc(2026, 3, 1, 13),
        engineVersion: 'synthetic-fixture-engine',
        referenceFixturesPassed: fixturesPassed,
      );
}
