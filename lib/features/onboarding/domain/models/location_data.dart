import '../../../location/domain/city_configuration.dart';

class CountryData {
  final String name;
  final String code;
  final String flag;
  final String marketLabel;
  final List<String> cities;

  const CountryData({
    required this.name,
    required this.code,
    required this.flag,
    required this.marketLabel,
    required this.cities,
  });
}

/// V1 launches in Pakistan. This repository boundary can later be backed by
/// the remotely managed city catalogue without changing presentation code.
class LocationRepository {
  static const List<String> launchCities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Hyderabad',
    'Gujranwala',
    'Other city',
  ];

  static const CountryData pakistan = CountryData(
    name: 'Pakistan',
    code: 'PK',
    flag: '🇵🇰',
    marketLabel: 'Pakistan Market',
    cities: launchCities,
  );

  static const List<CountryData> countries = [pakistan];

  static List<CountryData> get sortedCountries => countries;

  static CountryData get defaultCountry => pakistan;

  /// Converts a previously verified published release into runtime UI data.
  /// A missing release deliberately retains the bundled V1 fallback.
  static CountryData fromConfiguration(
    PublishedCityConfiguration? configuration,
  ) {
    if (configuration == null) return pakistan;
    return CountryData(
      name: pakistan.name,
      code: configuration.countryCode,
      flag: pakistan.flag,
      marketLabel: pakistan.marketLabel,
      cities: List.unmodifiable(
        configuration.enabledCities.map((city) => city.displayName),
      ),
    );
  }

  static CountryData findByCode(String code) => pakistan;
}
