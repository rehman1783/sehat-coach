import '../../account/domain/authenticated_owner_session.dart';
import '../../onboarding/domain/models/onboarding_state.dart';
import 'fasting_safety.dart';
import 'fasting_schedule.dart';

class FastingPreferencesRecord {
  FastingPreferencesRecord({
    required this.ownerId,
    required this.enabled,
    required this.schedule,
    required this.revision,
    required this.updatedAtUtc,
  }) {
    if (ownerId.trim().isEmpty) throw ArgumentError('Owner is required');
    if (revision < 1) throw ArgumentError.value(revision, 'revision');
    if (!updatedAtUtc.isUtc) throw ArgumentError('Update time must be UTC');
    if (enabled && schedule == null) {
      throw ArgumentError('Enabled fasting preferences require a schedule');
    }
  }

  final String ownerId;
  final bool enabled;
  final FastingSchedule? schedule;
  final int revision;
  final DateTime updatedAtUtc;
}

abstract interface class FastingPreferencesRepository {
  Future<FastingPreferencesRecord?> read(String ownerId);
  Future<void> save(FastingPreferencesRecord preferences);
}

abstract interface class FastingPreferencesClock {
  DateTime nowUtc();
}

class SystemFastingPreferencesClock implements FastingPreferencesClock {
  const SystemFastingPreferencesClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class UnsafeFastingActivation implements Exception {
  const UnsafeFastingActivation(this.assessment);
  final FastingSafetyAssessment assessment;
}

class SaveFastingPreferencesUseCase {
  const SaveFastingPreferencesUseCase({
    required this.session,
    required this.repository,
    this.safety = const FastingSafetyPolicy(),
    this.clock = const SystemFastingPreferencesClock(),
  });

  final AuthenticatedOwnerSession session;
  final FastingPreferencesRepository repository;
  final FastingSafetyPolicy safety;
  final FastingPreferencesClock clock;

  Future<FastingPreferencesRecord> execute({
    required OnboardingState profile,
    required bool enabled,
    FastingSchedule? schedule,
  }) => session.withOwner((ownerId) async {
    final assessment = safety.assess(profile);
    if (enabled && assessment.blockAutomaticPlan) {
      throw UnsafeFastingActivation(assessment);
    }
    final existing = await repository.read(ownerId);
    final record = FastingPreferencesRecord(
      ownerId: ownerId,
      enabled: enabled,
      schedule: schedule,
      revision: (existing?.revision ?? 0) + 1,
      updatedAtUtc: clock.nowUtc(),
    );
    await repository.save(record);
    return record;
  });
}
