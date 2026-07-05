import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_controle_leitura/core/constants/app_strings.dart';
import 'package:app_controle_leitura/presentation/blocs/auth/auth_bloc.dart';
import 'package:app_controle_leitura/presentation/pages/auth/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(AuthUnauthenticated());
  });

  // GoRouter mínimo: /login mostra a tela, /home só confirma navegação offline.
  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('mostra campos de e-mail/senha, Google e modo offline',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Dois campos de texto: e-mail e senha.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text(AppStrings.loginEmail), findsOneWidget);
    expect(find.text(AppStrings.loginPassword), findsOneWidget);

    // Botão Google e modo offline presentes.
    expect(find.text(AppStrings.loginGoogle), findsOneWidget);
    expect(find.text(AppStrings.continueOffline), findsOneWidget);
  });

  testWidgets('NÃO mostra login Microsoft', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.textContaining('Microsoft'), findsNothing);
  });

  testWidgets('alterna entre Entrar e Criar conta', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Estado inicial: modo login mostra "Entrar" e o link "Criar conta".
    expect(find.widgetWithText(ElevatedButton, AppStrings.loginEnter),
        findsOneWidget);
    expect(find.widgetWithText(TextButton, AppStrings.loginCreateAccount),
        findsOneWidget);

    // Toca em "Criar conta" → botão primário vira "Criar conta".
    await tester.tap(
        find.widgetWithText(TextButton, AppStrings.loginCreateAccount));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, AppStrings.loginCreateAccount),
        findsOneWidget);
    expect(find.widgetWithText(TextButton, AppStrings.loginHaveAccount),
        findsOneWidget);
  });

  testWidgets('valida e-mail/senha antes de disparar evento', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Submete vazio → mostra erros de validação e não dispara evento.
    await tester
        .tap(find.widgetWithText(ElevatedButton, AppStrings.loginEnter));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginEmailRequired), findsOneWidget);
    expect(find.text(AppStrings.loginPasswordRequired), findsOneWidget);
    verifyNever(() => authBloc.add(any(that: isA<AuthEmailSignInRequested>())));
  });

  testWidgets('login válido dispara AuthEmailSignInRequested', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).first, 'leitor@exemplo.com');
    await tester.enterText(find.byType(TextFormField).last, 'segredo123');
    await tester
        .tap(find.widgetWithText(ElevatedButton, AppStrings.loginEnter));
    await tester.pumpAndSettle();

    verify(() => authBloc.add(any(that: isA<AuthEmailSignInRequested>())))
        .called(1);
  });

  testWidgets('"Continuar sem login" navega para /home', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppStrings.continueOffline));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.continueOffline));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
