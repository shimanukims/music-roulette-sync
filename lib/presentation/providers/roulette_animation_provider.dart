import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rouletteAnimationProvider = StateNotifierProvider<RouletteAnimationNotifier, bool>((ref) {
  return RouletteAnimationNotifier();
});

class RouletteAnimationNotifier extends StateNotifier<bool> {
  static const _key = 'roulette_animation';
  
  RouletteAnimationNotifier() : super(true) {
    _loadAnimationSetting();
  }

  Future<void> _loadAnimationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}