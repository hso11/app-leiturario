import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda se o usuário já viu o tutorial inicial. A flag é carregada na memória
/// no boot (em main.dart) para permitir uma checagem síncrona na home.
@lazySingleton
class OnboardingService {
  static const _keySeen = 'onboarding_tutorial_seen';
  bool _seen = false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _seen = prefs.getBool(_keySeen) ?? false;
  }

  bool get hasSeenTutorial => _seen;

  Future<void> markSeen() async {
    _seen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeen, true);
  }
}
