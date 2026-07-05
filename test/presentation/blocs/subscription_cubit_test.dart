import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_controle_leitura/data/services/subscription_service.dart';
import 'package:app_controle_leitura/presentation/blocs/subscription/subscription_cubit.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}

void main() {
  late MockSubscriptionService mockService;
  late StreamController<bool> premiumStreamController;

  setUp(() {
    mockService = MockSubscriptionService();
    premiumStreamController = StreamController<bool>.broadcast();
    when(() => mockService.premiumStream)
        .thenAnswer((_) => premiumStreamController.stream);
    when(() => mockService.premiumPrice).thenReturn(null);
  });

  tearDown(() {
    premiumStreamController.close();
  });

  group('SubscriptionCubit', () {
    test('initial state is SubscriptionLoading', () {
      when(() => mockService.isPremium).thenReturn(false);
      final cubit = SubscriptionCubit(mockService);
      expect(cubit.state, isA<SubscriptionLoading>());
      cubit.close();
    });

    group('initialize', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits SubscriptionFree when not premium',
        build: () {
          when(() => mockService.isPremium).thenReturn(false);
          return SubscriptionCubit(mockService);
        },
        act: (cubit) => cubit.initialize(),
        expect: () => [isA<SubscriptionFree>()],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits SubscriptionPremium when premium cached',
        build: () {
          when(() => mockService.isPremium).thenReturn(true);
          return SubscriptionCubit(mockService);
        },
        act: (cubit) => cubit.initialize(),
        expect: () => [isA<SubscriptionPremium>()],
      );
    });

    group('purchasePremium', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [Loading] then Premium via stream on success',
        build: () {
          when(() => mockService.isPremium).thenReturn(false);
          when(() => mockService.purchase()).thenAnswer((_) async {
            Future.delayed(
              const Duration(milliseconds: 10),
              () => premiumStreamController.add(true),
            );
            return true;
          });
          return SubscriptionCubit(mockService);
        },
        act: (cubit) => cubit.purchasePremium(),
        wait: const Duration(milliseconds: 50),
        expect: () => [isA<SubscriptionLoading>(), isA<SubscriptionPremium>()],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits [Loading, Free] when product not available',
        build: () {
          when(() => mockService.isPremium).thenReturn(false);
          when(() => mockService.purchase()).thenAnswer((_) async => false);
          return SubscriptionCubit(mockService);
        },
        act: (cubit) => cubit.purchasePremium(),
        expect: () => [isA<SubscriptionLoading>(), isA<SubscriptionFree>()],
      );
    });

    group('premiumStream', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits Premium when service stream fires true',
        build: () {
          when(() => mockService.isPremium).thenReturn(false);
          return SubscriptionCubit(mockService);
        },
        act: (cubit) => premiumStreamController.add(true),
        expect: () => [isA<SubscriptionPremium>()],
      );
    });

    test('isPremium getter reflects current state', () {
      when(() => mockService.isPremium).thenReturn(true);
      final cubit = SubscriptionCubit(mockService)..initialize();
      expect(cubit.isPremium, isTrue);
      cubit.close();
    });

    test('premiumPrice delegates to service', () {
      when(() => mockService.isPremium).thenReturn(false);
      when(() => mockService.premiumPrice).thenReturn('R\$ 29,90');
      final cubit = SubscriptionCubit(mockService);
      expect(cubit.premiumPrice, 'R\$ 29,90');
      cubit.close();
    });
  });
}
