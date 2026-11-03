import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';

void main() {
  test('verified newer release replaces the cached configuration', () async {
    final old = _configuration('cities-1', DateTime.utc(2026, 10, 22));
    final newer = _configuration('cities-2', DateTime.utc(2026, 10, 23));
    final cache = _Cache(old);
    final manager = LastKnownGoodCityConfiguration(
      const _Verification(true),
      cache,
    );

    expect(await manager.refresh(newer), same(newer));
    expect(cache.value, same(newer));
    expect(cache.writes, 1);
  });

  test('failed verification retains the last-known-good release', () async {
    final old = _configuration('cities-1', DateTime.utc(2026, 10, 22));
    final cache = _Cache(old);
    final manager = LastKnownGoodCityConfiguration(
      const _Verification(false),
      cache,
    );

    expect(
      await manager.refresh(
        _configuration('cities-2', DateTime.utc(2026, 10, 23)),
      ),
      same(old),
    );
    expect(cache.writes, 0);
  });

  test(
    'older release and changed content under same ID are rejected',
    () async {
      final current = _configuration('cities-2', DateTime.utc(2026, 10, 23));
      final cache = _Cache(current);
      final manager = LastKnownGoodCityConfiguration(
        const _Verification(true),
        cache,
      );

      expect(
        await manager.refresh(
          _configuration('cities-1', DateTime.utc(2026, 10, 22)),
        ),
        same(current),
      );
      expect(
        await manager.refresh(
          _configuration(
            'cities-2',
            DateTime.utc(2026, 10, 24),
            checksum: 'sha256:changed',
          ),
        ),
        same(current),
      );
      expect(cache.writes, 0);
    },
  );

  test('verified release becomes first cache when none exists', () async {
    final cache = _Cache(null);
    final manager = LastKnownGoodCityConfiguration(
      const _Verification(true),
      cache,
    );
    final candidate = _configuration('cities-1', DateTime.utc(2026, 10, 23));

    expect(await manager.refresh(candidate), same(candidate));
    expect(await manager.load(), same(candidate));
  });
}

PublishedCityConfiguration _configuration(
  String id,
  DateTime publishedAt, {
  String checksum = 'sha256:valid',
}) => PublishedCityConfiguration(
  releaseId: id,
  version: id,
  countryCode: 'PK',
  contentChecksum: checksum,
  publishedAtUtc: publishedAt,
  cities: [
    CityConfigurationEntry(
      cityId: 'karachi',
      displayName: 'Karachi',
      sortOrder: 1,
    ),
    CityConfigurationEntry(
      cityId: 'other',
      displayName: 'Other city',
      sortOrder: 2,
      isOther: true,
    ),
  ],
);

class _Cache implements CityConfigurationCache {
  _Cache(this.value);
  PublishedCityConfiguration? value;
  int writes = 0;

  @override
  Future<PublishedCityConfiguration?> read() async => value;

  @override
  Future<void> write(PublishedCityConfiguration configuration) async {
    writes++;
    value = configuration;
  }
}

class _Verification implements CityConfigurationVerificationPort {
  const _Verification(this.valid);
  final bool valid;

  @override
  Future<bool> verify(PublishedCityConfiguration configuration) async => valid;
}
