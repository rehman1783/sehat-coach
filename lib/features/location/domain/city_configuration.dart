class CityConfigurationEntry {
  CityConfigurationEntry({
    required this.cityId,
    required this.displayName,
    required this.sortOrder,
    this.enabled = true,
    this.isOther = false,
    this.latitude,
    this.longitude,
  }) {
    if (cityId.trim().isEmpty || displayName.trim().isEmpty) {
      throw ArgumentError('City identity and display name are required');
    }
    if (sortOrder < 0) throw ArgumentError.value(sortOrder, 'sortOrder');
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('Latitude and longitude must be provided together');
    }
    if (latitude != null &&
        (!latitude!.isFinite || latitude! < -90 || latitude! > 90)) {
      throw ArgumentError.value(latitude, 'latitude');
    }
    if (longitude != null &&
        (!longitude!.isFinite || longitude! < -180 || longitude! > 180)) {
      throw ArgumentError.value(longitude, 'longitude');
    }
    if (isOther && latitude != null) {
      throw ArgumentError(
        'Other city cannot claim one representative coordinate',
      );
    }
  }

  final String cityId;
  final String displayName;
  final int sortOrder;
  final bool enabled;
  final bool isOther;
  final double? latitude;
  final double? longitude;

  bool get hasVerifiedCoordinates => latitude != null && longitude != null;
}

class PublishedCityConfiguration {
  PublishedCityConfiguration({
    required this.releaseId,
    required this.version,
    required this.countryCode,
    required this.contentChecksum,
    required this.publishedAtUtc,
    required List<CityConfigurationEntry> cities,
  }) : cities = List.unmodifiable(cities) {
    if (releaseId.trim().isEmpty ||
        version.trim().isEmpty ||
        contentChecksum.trim().isEmpty) {
      throw ArgumentError('City configuration release identity is required');
    }
    if (countryCode != 'PK') {
      throw ArgumentError('V1 city configuration must target Pakistan');
    }
    if (!publishedAtUtc.isUtc) {
      throw ArgumentError('Publication time must be UTC');
    }
    final enabled = this.cities.where((city) => city.enabled).toList();
    if (enabled.isEmpty) throw ArgumentError('At least one city is required');
    if (enabled.where((city) => city.isOther).length != 1) {
      throw ArgumentError('Exactly one enabled Other city option is required');
    }
    final ids = enabled.map((city) => city.cityId).toSet();
    if (ids.length != enabled.length) {
      throw ArgumentError('Enabled city IDs must be unique');
    }
  }

  final String releaseId;
  final String version;
  final String countryCode;
  final String contentChecksum;
  final DateTime publishedAtUtc;
  final List<CityConfigurationEntry> cities;

  List<CityConfigurationEntry> get enabledCities {
    final values = cities.where((city) => city.enabled).toList();
    values.sort((a, b) {
      if (a.isOther != b.isOther) return a.isOther ? 1 : -1;
      final order = a.sortOrder.compareTo(b.sortOrder);
      return order != 0 ? order : a.displayName.compareTo(b.displayName);
    });
    return List.unmodifiable(values);
  }
}

abstract interface class CityConfigurationVerificationPort {
  Future<bool> verify(PublishedCityConfiguration configuration);
}

class VerifiedCityConfigurationLoader {
  const VerifiedCityConfigurationLoader(this._verification);

  final CityConfigurationVerificationPort _verification;

  Future<PublishedCityConfiguration?> accept(
    PublishedCityConfiguration configuration,
  ) async => await _verification.verify(configuration) ? configuration : null;
}

abstract interface class CityConfigurationCache {
  Future<PublishedCityConfiguration?> read();
  Future<void> write(PublishedCityConfiguration configuration);
}

class LastKnownGoodCityConfiguration {
  const LastKnownGoodCityConfiguration(this._verification, this._cache);

  final CityConfigurationVerificationPort _verification;
  final CityConfigurationCache _cache;

  Future<PublishedCityConfiguration?> load() => _cache.read();

  Future<PublishedCityConfiguration?> refresh(
    PublishedCityConfiguration candidate,
  ) async {
    final current = await _cache.read();
    if (!await _verification.verify(candidate)) return current;
    if (current != null) {
      if (candidate.publishedAtUtc.isBefore(current.publishedAtUtc)) {
        return current;
      }
      if (candidate.releaseId == current.releaseId &&
          candidate.contentChecksum != current.contentChecksum) {
        return current;
      }
      if (candidate.publishedAtUtc == current.publishedAtUtc &&
          candidate.releaseId != current.releaseId) {
        return current;
      }
    }
    await _cache.write(candidate);
    return candidate;
  }
}
