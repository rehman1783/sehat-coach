import '../../sync/domain/local_change_store.dart';
import '../domain/fasting_preferences.dart';
import '../domain/fasting_schedule.dart';

class LocalChangeFastingPreferencesRepository
    implements FastingPreferencesRepository {
  LocalChangeFastingPreferencesRepository(this._store, this._ownerId) {
    if (_ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
  }

  static const entityType = 'fasting_preferences';
  static const entityKey = 'preferences';
  static const schemaVersion = 1;

  final LocalChangeStore _store;
  final String _ownerId;

  @override
  Future<FastingPreferencesRecord?> read(String ownerId) async {
    _verifyOwner(ownerId);
    final local = await _store.read(ownerId, entityType, entityKey);
    if (local == null) return null;
    final payload = local.payload;
    final scheduleJson = payload['schedule'];
    return FastingPreferencesRecord(
      ownerId: ownerId,
      enabled: payload['enabled'] as bool,
      schedule: scheduleJson == null
          ? null
          : _decodeSchedule((scheduleJson as Map).cast<String, Object?>()),
      revision: local.revision,
      updatedAtUtc: DateTime.parse(payload['updatedAtUtc'] as String).toUtc(),
    );
  }

  @override
  Future<void> save(FastingPreferencesRecord preferences) async {
    _verifyOwner(preferences.ownerId);
    final expectedRevision = preferences.revision - 1;
    final change = await _store.commit(
      ownerId: _ownerId,
      operationId: 'fasting-preferences:r${preferences.revision}',
      entityType: entityType,
      entityKey: entityKey,
      expectedRevision: expectedRevision,
      payload: {
        'schemaVersion': schemaVersion,
        'enabled': preferences.enabled,
        'schedule': preferences.schedule == null
            ? null
            : _encodeSchedule(preferences.schedule!),
        'updatedAtUtc': preferences.updatedAtUtc.toIso8601String(),
      },
    );
    if (change.newRevision != preferences.revision) {
      throw StateError('Unexpected fasting preference revision');
    }
  }

  Map<String, Object?> _encodeSchedule(FastingSchedule schedule) => {
    'type': schedule.type.name,
    'suhoorReminderEnabled': schedule.suhoorReminderEnabled,
    'iftarReminderEnabled': schedule.iftarReminderEnabled,
    'windows': [
      for (final window in schedule.windows)
        {
          'startsAtUtc': window.startsAtUtc.toIso8601String(),
          'endsAtUtc': window.endsAtUtc.toIso8601String(),
          'timezoneOffsetMinutes': window.timezoneOffsetMinutes,
          'source': window.source.name,
        },
    ],
  };

  FastingSchedule _decodeSchedule(Map<String, Object?> value) {
    final windows = (value['windows'] as List).cast<Map>();
    return FastingSchedule(
      type: FastingScheduleType.values.byName(value['type'] as String),
      windows: [
        for (final raw in windows)
          FastingDayWindow(
            startsAtUtc: DateTime.parse(raw['startsAtUtc'] as String).toUtc(),
            endsAtUtc: DateTime.parse(raw['endsAtUtc'] as String).toUtc(),
            timezoneOffsetMinutes: raw['timezoneOffsetMinutes'] as int,
            source: FastingTimeSource.values.byName(raw['source'] as String),
          ),
      ],
      suhoorReminderEnabled: value['suhoorReminderEnabled'] as bool,
      iftarReminderEnabled: value['iftarReminderEnabled'] as bool,
    );
  }

  void _verifyOwner(String ownerId) {
    if (ownerId != _ownerId) {
      throw StateError('Fasting preferences belong to another account');
    }
  }
}
