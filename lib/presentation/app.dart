import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../injection.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/book/book_bloc.dart';
import 'blocs/sync/sync_cubit.dart';
import 'blocs/theme/theme_cubit.dart';
import 'router/app_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class BookTrackerApp extends StatefulWidget {
  const BookTrackerApp({super.key});

  @override
  State<BookTrackerApp> createState() => _BookTrackerAppState();
}

class _BookTrackerAppState extends State<BookTrackerApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(AuthCheckRequested());
    _router = createAppRouter(_authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E2A3A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..loadTheme()),
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: getIt<BookBloc>()..add(BookLoadRequested())),
        BlocProvider.value(value: getIt<SyncCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
