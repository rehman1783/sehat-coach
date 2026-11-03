import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/features/onboarding/domain/models/location_data.dart';

void main() {
  test('V1 exposes approved Pakistan launch cities and Other city', () {
    expect(LocationRepository.countries, hasLength(1));
    expect(LocationRepository.defaultCountry.code, 'PK');
    expect(LocationRepository.launchCities, [
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
    ]);
  });
}
