import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/location/domain/city_configuration.dart';
import 'package:sehat_coach/features/onboarding/domain/models/location_data.dart';

void main() {
  test(
    'verified published release updates cities without changing app code',
    () async {
      final configuration = _configuration([
        _city('lahore', 'Lahore', 2),
        _city('karachi', 'Karachi', 1),
        _city('sialkot', 'Sialkot', 3),
        _city('other', 'Other city', 0, other: true),
      ]);
      final accepted = await const VerifiedCityConfigurationLoader(
        _Verification(true),
      ).accept(configuration);
      final country = LocationRepository.fromConfiguration(accepted);

      expect(country.cities, ['Karachi', 'Lahore', 'Sialkot', 'Other city']);
      expect(country.code, 'PK');
    },
  );

  test('failed verification retains bundled approved launch list', () async {
    final accepted =
        await const VerifiedCityConfigurationLoader(_Verification(false))
            .accept(
              _configuration([
                _city('fake', 'Fake city', 1),
                _city('other', 'Other city', 2, other: true),
              ]),
            );

    expect(accepted, isNull);
    expect(
      LocationRepository.fromConfiguration(accepted).cities,
      LocationRepository.launchCities,
    );
  });

  test('release requires Pakistan, unique cities and one Other option', () {
    expect(
      () => _configuration([_city('karachi', 'Karachi', 1)]),
      throwsArgumentError,
    );
    expect(
      () => _configuration([
        _city('same', 'Karachi', 1),
        _city('same', 'Lahore', 2),
        _city('other', 'Other city', 3, other: true),
      ]),
      throwsArgumentError,
    );
    expect(
      () => PublishedCityConfiguration(
        releaseId: 'cities-1',
        version: '1',
        countryCode: 'US',
        contentChecksum: 'sha256:test',
        publishedAtUtc: DateTime.utc(2026, 10, 23),
        cities: [_city('other', 'Other', 1, other: true)],
      ),
      throwsArgumentError,
    );
  });
}

PublishedCityConfiguration _configuration(
  List<CityConfigurationEntry> cities,
) => PublishedCityConfiguration(
  releaseId: 'cities-1',
  version: '1',
  countryCode: 'PK',
  contentChecksum: 'sha256:synthetic',
  publishedAtUtc: DateTime.utc(2026, 10, 23),
  cities: cities,
);

CityConfigurationEntry _city(
  String id,
  String name,
  int order, {
  bool other = false,
}) => CityConfigurationEntry(
  cityId: id,
  displayName: name,
  sortOrder: order,
  isOther: other,
);

class _Verification implements CityConfigurationVerificationPort {
  const _Verification(this.valid);

  final bool valid;

  @override
  Future<bool> verify(PublishedCityConfiguration configuration) async => valid;
}
