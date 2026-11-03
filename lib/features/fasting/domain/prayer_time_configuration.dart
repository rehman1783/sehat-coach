import '../../location/domain/city_configuration.dart';
import 'fasting_schedule.dart';

enum PrayerCoordinateSource { selectedCity, preciseLocationWithPermission }

class PrayerCoordinates {
  PrayerCoordinates({
    required this.latitude,
    required this.longitude,
    required this.source,
    this.cityId,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(longitude, 'longitude');
    }
    if (source == PrayerCoordinateSource.selectedCity &&
        (cityId == null || cityId!.trim().isEmpty)) {
      throw ArgumentError('Selected-city coordinates require a city ID');
    }
  }

  factory PrayerCoordinates.fromVerifiedCity(CityConfigurationEntry city) {
    if (!city.hasVerifiedCoordinates || city.isOther) {
      throw StateError('The selected city has no verified coordinates');
    }
    return PrayerCoordinates(
      latitude: city.latitude!,
      longitude: city.longitude!,
      source: PrayerCoordinateSource.selectedCity,
      cityId: city.cityId,
    );
  }

  final double latitude;
  final double longitude;
  final PrayerCoordinateSource source;
  final String? cityId;
}

class PrayerCalculationMethod {
  PrayerCalculationMethod({
    required this.id,
    required this.displayName,
    required this.parameterVersion,
    required this.reviewApproved,
  }) {
    if (id.trim().isEmpty ||
        displayName.trim().isEmpty ||
        parameterVersion.trim().isEmpty) {
      throw ArgumentError('Calculation method metadata is required');
    }
  }

  final String id;
  final String displayName;
  final String parameterVersion;
  final bool reviewApproved;
}

class PrayerMinuteAdjustments {
  PrayerMinuteAdjustments({this.fajrMinutes = 0, this.maghribMinutes = 0}) {
    if (fajrMinutes < -120 ||
        fajrMinutes > 120 ||
        maghribMinutes < -120 ||
        maghribMinutes > 120) {
      throw ArgumentError('Manual prayer adjustments must be within two hours');
    }
  }

  final int fajrMinutes;
  final int maghribMinutes;
}

class PrayerTimeRequest {
  PrayerTimeRequest({
    required this.localDate,
    required this.timezoneOffsetMinutes,
    required this.coordinates,
    required this.method,
  }) {
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw ArgumentError.value(timezoneOffsetMinutes, 'timezoneOffsetMinutes');
    }
    if (localDate.isUtc ||
        localDate.hour != 0 ||
        localDate.minute != 0 ||
        localDate.second != 0 ||
        localDate.millisecond != 0 ||
        localDate.microsecond != 0) {
      throw ArgumentError('Local prayer date must be a local midnight value');
    }
  }

  final DateTime localDate;
  final int timezoneOffsetMinutes;
  final PrayerCoordinates coordinates;
  final PrayerCalculationMethod method;
}

class CalculatedPrayerTimes {
  CalculatedPrayerTimes({
    required this.fajrUtc,
    required this.maghribUtc,
    required this.engineVersion,
    required this.referenceFixturesPassed,
  }) {
    if (!fajrUtc.isUtc || !maghribUtc.isUtc || !maghribUtc.isAfter(fajrUtc)) {
      throw ArgumentError('Prayer calculation must provide an ordered UTC day');
    }
    if (engineVersion.trim().isEmpty) {
      throw ArgumentError('Prayer calculation engine version is required');
    }
  }

  final DateTime fajrUtc;
  final DateTime maghribUtc;
  final String engineVersion;
  final bool referenceFixturesPassed;
}

abstract interface class PrayerTimeCalculator {
  Future<CalculatedPrayerTimes> calculate(PrayerTimeRequest request);
}

class UnverifiedPrayerCalculation implements Exception {
  const UnverifiedPrayerCalculation(this.message);
  final String message;
}

class CreatePrayerFastingWindow {
  const CreatePrayerFastingWindow(this._calculator);

  final PrayerTimeCalculator _calculator;

  Future<FastingDayWindow> execute({
    required PrayerTimeRequest request,
    PrayerMinuteAdjustments? adjustments,
  }) async {
    if (!request.method.reviewApproved) {
      throw const UnverifiedPrayerCalculation(
        'The selected calculation method has not been approved.',
      );
    }
    final result = await _calculator.calculate(request);
    if (!result.referenceFixturesPassed) {
      throw const UnverifiedPrayerCalculation(
        'Prayer calculation reference fixtures have not passed.',
      );
    }
    final correction = adjustments ?? PrayerMinuteAdjustments();
    return FastingDayWindow(
      startsAtUtc: result.fajrUtc.add(
        Duration(minutes: correction.fajrMinutes),
      ),
      endsAtUtc: result.maghribUtc.add(
        Duration(minutes: correction.maghribMinutes),
      ),
      timezoneOffsetMinutes: request.timezoneOffsetMinutes,
      source: FastingTimeSource.verifiedPrayerCalculation,
    );
  }
}
