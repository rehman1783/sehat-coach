import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehat_coach/core/bootstrap/activated_account_features.dart';
import 'package:sehat_coach/core/data/local/account_database_service.dart';
import 'package:sehat_coach/core/data/local/account_key_resolver.dart';
import 'package:sehat_coach/features/account/domain/authenticated_owner_session.dart';
import 'package:sehat_coach/features/onboarding/domain/models/onboarding_state.dart';
import 'package:sehat_coach/features/onboarding/presentation/widgets/authenticated_profile_gate.dart';

void main() {
  testWidgets('builds private destination only from loaded durable profile', (
    tester,
  ) async {
    final pending = Completer<OnboardingState?>();
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedProfileGate(
          loadProfile: () => pending.future,
          profileBuilder: (profile) => Text('Home ${profile.city}'),
          missingProfile: const Text('Finish onboarding'),
        ),
      ),
    );
    expect(find.textContaining('Home'), findsNothing);
    pending.complete(OnboardingState(city: 'Lahore'));
    await tester.pump();
    expect(find.text('Home Lahore'), findsOneWidget);
  });

  testWidgets('missing profile resumes onboarding instead of generic Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedProfileGate(
          loadProfile: () async => null,
          profileBuilder: (_) => const Text('Private Home'),
          missingProfile: const Text('Finish onboarding'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Finish onboarding'), findsOneWidget);
    expect(find.text('Private Home'), findsNothing);
  });

  testWidgets('committed profile refresh replaces onboarding with Home', (
    tester,
  ) async {
    final refresh = ValueNotifier<int>(0);
    OnboardingState? durableProfile;
    addTearDown(refresh.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedProfileGate(
          loadProfile: () async => durableProfile,
          profileBuilder: (profile) => Text('Home ${profile.city}'),
          missingProfile: const Text('Finish onboarding'),
          refresh: refresh,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Finish onboarding'), findsOneWidget);

    durableProfile = OnboardingState(city: 'Islamabad');
    refresh.value++;
    await tester.pump();

    expect(find.text('Home Islamabad'), findsOneWidget);
    expect(find.text('Finish onboarding'), findsNothing);
  });

  testWidgets('read failure stays private and retries successfully', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticatedProfileGate(
          loadProfile: () async {
            attempts++;
            if (attempts == 1) throw const FormatException('secret payload');
            return OnboardingState(city: 'Karachi');
          },
          profileBuilder: (profile) => Text('Home ${profile.city}'),
          missingProfile: const Text('Finish onboarding'),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('secret payload'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('Home Karachi'), findsOneWidget);
  });

  test(
    'composed loader reads only the current encrypted owner profile',
    () async {
      final directory = await Directory.systemTemp.createTemp('sehat-load-');
      final service = AccountDatabaseService(
        directory,
        AccountKeyResolver(_Vault()),
      );
      final session = _Session('owner-a');
      final features = ActivatedAccountFeatures(
        databases: service,
        ownerSession: session,
      );
      final handoff = await features.createOnboardingProfileHandoff(
        onCommitted: (_) async {},
      );
      await handoff.complete(
        profile: OnboardingState(age: 30, city: 'Multan'),
        adultAgeConfirmed: true,
      );
      final loader = await features.createProfileLoader();
      expect((await loader.load())?.city, 'Multan');

      session.ownerId = 'owner-b';
      await expectLater(loader.load(), throwsStateError);

      await service.close();
      await directory.delete(recursive: true);
    },
  );
}

class _Session implements AuthenticatedOwnerSession {
  _Session(this.ownerId);
  String ownerId;

  @override
  Future<T> withOwner<T>(Future<T> Function(String ownerId) operation) =>
      operation(ownerId);
}

class _Vault implements AccountKeyVault {
  final values = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String ownerId) async => values[ownerId];

  @override
  Future<Uint8List> createIfAbsent(String ownerId, Uint8List candidate) async =>
      values.putIfAbsent(ownerId, () => Uint8List.fromList(candidate));

  @override
  Future<void> delete(String ownerId) async => values.remove(ownerId);
}
