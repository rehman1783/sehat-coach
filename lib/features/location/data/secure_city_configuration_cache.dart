import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/city_configuration.dart';

class SecureCityConfigurationCache implements CityConfigurationCache {
  const SecureCityConfigurationCache(this._storage);

  static const storageKey = 'sehat_coach.city_configuration.last_known_good';
  final FlutterSecureStorage _storage;

  @override
  Future<PublishedCityConfiguration?> read() async {
    final value = await _storage.read(key: storageKey);
    if (value == null) return null;
    try {
      final json = (jsonDecode(value) as Map).cast<String, Object?>();
      final citiesJson = (json['cities'] as List).cast<Map>();
      return PublishedCityConfiguration(
        releaseId: json['releaseId'] as String,
        version: json['version'] as String,
        countryCode: json['countryCode'] as String,
        contentChecksum: json['contentChecksum'] as String,
        publishedAtUtc: DateTime.parse(json['publishedAtUtc'] as String)
            .toUtc(),
        cities: [
          for (final raw in citiesJson)
            CityConfigurationEntry(
              cityId: raw['cityId'] as String,
              displayName: raw['displayName'] as String,
              sortOrder: raw['sortOrder'] as int,
              enabled: raw['enabled'] as bool,
              isOther: raw['isOther'] as bool,
              latitude: (raw['latitude'] as num?)?.toDouble(),
              longitude: (raw['longitude'] as num?)?.toDouble(),
            ),
        ],
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(PublishedCityConfiguration configuration) =>
      _storage.write(
        key: storageKey,
        value: jsonEncode({
          'releaseId': configuration.releaseId,
          'version': configuration.version,
          'countryCode': configuration.countryCode,
          'contentChecksum': configuration.contentChecksum,
          'publishedAtUtc': configuration.publishedAtUtc.toIso8601String(),
          'cities': [
            for (final city in configuration.cities)
              {
                'cityId': city.cityId,
                'displayName': city.displayName,
                'sortOrder': city.sortOrder,
                'enabled': city.enabled,
                'isOther': city.isOther,
                'latitude': city.latitude,
                'longitude': city.longitude,
              },
          ],
        }),
      );
}
