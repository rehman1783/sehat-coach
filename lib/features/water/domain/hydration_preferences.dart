import '../../account/domain/authenticated_owner_session.dart';

enum HydrationTargetSource { none, user, clinician }

class HydrationPreferencesRecord {
  HydrationPreferencesRecord({
    required this.ownerId,
    required this.targetMilliliters,
    required this.targetSource,
    required this.restrictionNote,
    required this.revision,
    required this.updatedAtUtc,
    this.remindersEnabled = false,
    this.reminderStartMinute = 480,
    this.reminderEndMinute = 1200,
    this.reminderIntervalMinutes = 120,
  }) {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner ID is required');
    if (targetSource == HydrationTargetSource.none &&
        targetMilliliters != null) {
      throw ArgumentError('No target source cannot retain a target');
    }
    if (targetSource != HydrationTargetSource.none &&
        targetMilliliters == null) {
      throw ArgumentError('A target source requires a target');
    }
    if (targetMilliliters case final value?) {
      if (value < 250 || value > 10000) {
        throw ArgumentError.value(value, 'targetMilliliters');
      }
    }
    if (restrictionNote.length > 500) {
      throw ArgumentError('Hydration note is too long');
    }
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (reminderStartMinute < 0 || reminderStartMinute > 1439) {
      throw ArgumentError.value(reminderStartMinute, 'reminderStartMinute');
    }
    if (reminderEndMinute <= reminderStartMinute || reminderEndMinute > 1439) {
      throw ArgumentError.value(reminderEndMinute, 'reminderEndMinute');
    }
    if (reminderIntervalMinutes < 30 || reminderIntervalMinutes > 720) {
      throw ArgumentError.value(
        reminderIntervalMinutes,
        'reminderIntervalMinutes',
      );
    }
    if (!updatedAtUtc.isUtc) {
      throw ArgumentError('Hydration preference timestamp must be UTC');
    }
  }

  final String ownerId;
  final int? targetMilliliters;
  final HydrationTargetSource targetSource;
  final String restrictionNote;
  final int revision;
  final DateTime updatedAtUtc;
  final bool remindersEnabled;
  final int reminderStartMinute;
  final int reminderEndMinute;
  final int reminderIntervalMinutes;
}

abstract interface class HydrationPreferencesRepository {
  Stream<HydrationPreferencesRecord?> watch();
  Future<void> save(HydrationPreferencesRecord preferences);
  Future<int> readRevision();
}

abstract interface class HydrationPreferencesClock {
  DateTime nowUtc();
}

class SaveHydrationPreferencesUseCase {
  const SaveHydrationPreferencesUseCase({
    required this.session,
    required this.repository,
    required this.clock,
  });

  final AuthenticatedOwnerSession session;
  final HydrationPreferencesRepository repository;
  final HydrationPreferencesClock clock;

  Future<HydrationPreferencesRecord> execute({
    required int? targetMilliliters,
    required HydrationTargetSource source,
    String restrictionNote = '',
    bool remindersEnabled = false,
    int reminderStartMinute = 480,
    int reminderEndMinute = 1200,
    int reminderIntervalMinutes = 120,
  }) => session.withOwner((ownerId) async {
    final record = HydrationPreferencesRecord(
      ownerId: ownerId,
      targetMilliliters: targetMilliliters,
      targetSource: source,
      restrictionNote: restrictionNote.trim(),
      revision: await repository.readRevision() + 1,
      updatedAtUtc: clock.nowUtc(),
      remindersEnabled: remindersEnabled,
      reminderStartMinute: reminderStartMinute,
      reminderEndMinute: reminderEndMinute,
      reminderIntervalMinutes: reminderIntervalMinutes,
    );
    await repository.save(record);
    return record;
  });
}
