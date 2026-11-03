import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'privacy_safe_diagnostics.dart';

class DetectedLocation {
  final String countryCode;
  final String countryName;
  final String city;
  final String detectedVia;
  final String currency;
  final bool isDesiMarket;

  const DetectedLocation({
    required this.countryCode,
    required this.countryName,
    required this.city,
    required this.detectedVia,
    required this.currency,
    required this.isDesiMarket,
  });

  Map<String, dynamic> toJson() => {
    'location': {
      'countryCode': countryCode,
      'countryName': countryName,
      'city': city,
      'detectedVia': detectedVia,
      'currency': currency,
      'isDesiMarket': isDesiMarket,
    },
  };
}

class GeoDetector {
  static const Map<String, Map<String, String>> _countryMeta = {
    'PK': {
      'name': 'Pakistan',
      'currency': 'PKR',
      'city': 'Lahore',
      'desi': 'true',
    },
    'GB': {
      'name': 'United Kingdom',
      'currency': 'GBP',
      'city': 'London',
      'desi': 'false',
    },
    'US': {
      'name': 'United States',
      'currency': 'USD',
      'city': 'New York',
      'desi': 'false',
    },
    'AE': {
      'name': 'United Arab Emirates',
      'currency': 'AED',
      'city': 'Dubai',
      'desi': 'true',
    },
    'CA': {
      'name': 'Canada',
      'currency': 'CAD',
      'city': 'Toronto',
      'desi': 'false',
    },
    'SA': {
      'name': 'Saudi Arabia',
      'currency': 'SAR',
      'city': 'Riyadh',
      'desi': 'true',
    },
    'QA': {'name': 'Qatar', 'currency': 'QAR', 'city': 'Doha', 'desi': 'true'},
    'OM': {'name': 'Oman', 'currency': 'OMR', 'city': 'Muscat', 'desi': 'true'},
    'KW': {
      'name': 'Kuwait',
      'currency': 'KWD',
      'city': 'Kuwait City',
      'desi': 'true',
    },
    'BH': {
      'name': 'Bahrain',
      'currency': 'BHD',
      'city': 'Manama',
      'desi': 'true',
    },
    'IN': {'name': 'India', 'currency': 'INR', 'city': 'Delhi', 'desi': 'true'},
    'AU': {
      'name': 'Australia',
      'currency': 'AUD',
      'city': 'Sydney',
      'desi': 'false',
    },
  };

  /// Tier 1: Zero-Permission Native Signals (Runs <50ms synchronously)
  static DetectedLocation? detectTier1() {
    try {
      // 1. Inspect System Locale (e.g. "en_PK" or "ur_PK")
      String localeCountry = '';
      if (!kIsWeb) {
        final String locale = Platform.localeName;
        if (locale.contains('_') || locale.contains('-')) {
          final parts = locale.split(RegExp(r'[_-]'));
          if (parts.length > 1) {
            localeCountry = parts.last.toUpperCase();
          }
        }
      }

      if (localeCountry == 'PK') {
        return _buildResult('PK', 'Lahore', 'locale_timezone');
      }

      // 2. System Timezone Offset (PST / Asia/Karachi is UTC+5)
      final DateTime now = DateTime.now();
      final Duration offset = now.timeZoneOffset;
      final String tzName = now.timeZoneName.toUpperCase();

      if (offset.inHours == 5 ||
          tzName.contains('PKT') ||
          tzName.contains('PAKISTAN') ||
          tzName.contains('KARACHI')) {
        return _buildResult('PK', 'Lahore', 'locale_timezone');
      } else if (offset.inHours == 0 || offset.inHours == 1) {
        return _buildResult('GB', 'London', 'locale_timezone');
      } else if (offset.inHours == 4) {
        return _buildResult('AE', 'Dubai', 'locale_timezone');
      } else if (offset.inHours == 3) {
        return _buildResult('SA', 'Riyadh', 'locale_timezone');
      } else if (offset.inHours <= -4 && offset.inHours >= -8) {
        return _buildResult('US', 'New York', 'locale_timezone');
      }

      if (localeCountry.isNotEmpty && _countryMeta.containsKey(localeCountry)) {
        return _buildResult(
          localeCountry,
          _countryMeta[localeCountry]!['city']!,
          'locale_timezone',
        );
      }
    } catch (_) {
      privacySafeDiagnostics.event('geo.tier1.failed');
    }
    return null;
  }

  /// Tier 2: Network IP Fallback (HTTPS requests with 2.5s timeout)
  static Future<DetectedLocation?> detectTier2() async {
    final endpoints = [
      'https://ipapi.co/json/',
      'https://get.geojs.io/v1/ip/geo.json',
    ];

    for (final url in endpoints) {
      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
              },
            )
            .timeout(const Duration(milliseconds: 2500));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final String code =
              (data['countryCode'] ??
                      data['country_code'] ??
                      data['country'] ??
                      '')
                  .toString()
                  .toUpperCase();
          final String rawCity = (data['city'] ?? '').toString().trim();

          if (code.isNotEmpty && _countryMeta.containsKey(code)) {
            final defaultCity = _countryMeta[code]!['city']!;
            final finalCity = rawCity.isNotEmpty
                ? _formatCity(rawCity)
                : defaultCity;
            return _buildResult(code, finalCity, 'ip_lookup');
          }
        }
      } catch (_) {
        privacySafeDiagnostics.event('geo.tier2.failed');
      }
    }
    return null;
  }

  /// Full 3-Tier Cascade Execution
  static Future<DetectedLocation> detectLocation() async {
    // Attempt Tier 1
    final tier1Result = detectTier1();

    // Attempt Tier 2 (IP network detection for exact city)
    final tier2Result = await detectTier2();
    if (tier2Result != null) {
      return tier2Result;
    }

    if (tier1Result != null) {
      return tier1Result;
    }

    // Default fallback to Pakistan / Lahore
    return _buildResult('PK', 'Lahore', 'default');
  }

  static String _formatCity(String raw) {
    if (raw.isEmpty) return raw;
    final words = raw.split(RegExp(r'\s+'));
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  static DetectedLocation _buildResult(
    String code,
    String city,
    String source,
  ) {
    final meta = _countryMeta[code] ?? _countryMeta['PK']!;
    return DetectedLocation(
      countryCode: code,
      countryName: meta['name']!,
      city: city,
      detectedVia: source,
      currency: meta['currency']!,
      isDesiMarket: meta['desi'] == 'true',
    );
  }
}
