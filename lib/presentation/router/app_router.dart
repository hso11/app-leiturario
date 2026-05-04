import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../pages/auth/login_screen.dart';
import '../pages/home/home_screen.dart';
import '../pages/book_detail/book_detail_screen.dart';
import '../pages/notes_feed/notes_feed_screen.dart';
import '../pages/achievements/achievements_screen.dart';
import '../pages/settings/settings_screen.dart';
import '../pages/list_detail/list_detail_screen.dart';
import '../pages/reading_calendar/reading_calendar_screen.dart';

class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createAppRouter(AuthBloc authBloc) => GoRouter(
      initialLocation: '/home',
      refreshListenable: _AuthRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuth = authState is AuthAuthenticated;
        final isLoading =
            authState is AuthLoading || authState is AuthInitial;
        final isLogin = state.matchedLocation == '/login';

        if (isLoading) return null;
        if (!isAuth && !isLogin) return '/login';
        if (isAuth && isLogin) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return BookDetailScreen(bookId: bookId);
          },
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NotesFeedScreen(),
        ),
        GoRoute(
          path: '/achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/book/:id/calendar',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return ReadingCalendarScreen(bookId: bookId);
          },
        ),
        GoRoute(
          path: '/list/:id',
          builder: (context, state) {
            final listId = state.pathParameters['id']!;
            return ListDetailScreen(listId: listId);
          },
        ),
      ],
    );
