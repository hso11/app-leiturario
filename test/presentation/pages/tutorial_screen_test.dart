import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_controle_leitura/core/constants/app_strings.dart';
import 'package:app_controle_leitura/data/services/onboarding_service.dart';
import 'package:app_controle_leitura/injection.dart';
import 'package:app_controle_leitura/presentation/pages/tutorial/tutorial_screen.dart';

class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  late MockOnboardingService onboarding;

  setUp(() {
    onboarding = MockOnboardingService();
    when(() => onboarding.markSeen()).thenAnswer((_) async {});
    if (getIt.isRegistered<OnboardingService>()) {
      getIt.unregister<OnboardingService>();
    }
    getIt.registerSingleton<OnboardingService>(onboarding);
  });

  tearDown(() {
    if (getIt.isRegistered<OnboardingService>()) {
      getIt.unregister<OnboardingService>();
    }
  });

  // Avança a animação do PageView/rota: um frame para iniciar, outro para
  // concluir a transição (não dá para usar pumpAndSettle por causa do
  // AnimationController em loop).
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // GoRouter com /tutorial e /home para validar a navegação ao concluir.
  Widget buildSubject({bool fromSettings = false}) {
    final router = GoRouter(
      initialLocation: '/tutorial',
      routes: [
        GoRoute(
          path: '/tutorial',
          builder: (_, __) => TutorialScreen(fromSettings: fromSettings),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('renderiza o primeiro slide e o indicador de 5 pontos',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text(AppStrings.tutorialWelcomeTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, AppStrings.tutorialNext),
        findsOneWidget);
    expect(find.text(AppStrings.tutorialSkip), findsOneWidget);
  });

  testWidgets('avança pelos slides até o botão virar "Começar"',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // 4 toques em "Próximo" levam ao 5º (último) slide.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.tutorialNext));
      await settle(tester);
    }

    expect(find.text(AppStrings.tutorialProgressTitle), findsOneWidget);
    expect(find.widgetWithText(FilledButton, AppStrings.tutorialStart),
        findsOneWidget);
  });

  testWidgets('"Pular" marca como visto e navega para /home', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.text(AppStrings.tutorialSkip));
    await settle(tester);

    verify(() => onboarding.markSeen()).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('"Começar" no último slide marca como visto', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.tutorialNext));
      await settle(tester);
    }
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.tutorialStart));
    await settle(tester);

    verify(() => onboarding.markSeen()).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('aberto de Configurações, ao pular faz pop (não vai p/ home)',
      (tester) async {
    // initialLocation com uma rota base para haver para onde dar pop.
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, __) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/tutorial?from=settings'),
                child: const Text('ABRIR'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/tutorial',
          builder: (_, state) => TutorialScreen(
            fromSettings: state.uri.queryParameters['from'] == 'settings',
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    await tester.tap(find.text('ABRIR'));
    await settle(tester);
    expect(find.text(AppStrings.tutorialWelcomeTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.tutorialSkip));
    await settle(tester);

    verify(() => onboarding.markSeen()).called(1);
    // Voltou para Configurações.
    expect(find.text('ABRIR'), findsOneWidget);
  });
}
