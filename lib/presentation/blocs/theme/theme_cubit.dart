import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  static const _key = 'theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      emit(ThemeMode.dark);
    } else if (value == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }
}
