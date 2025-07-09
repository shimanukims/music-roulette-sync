import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Provider for music videos only setting
final musicVideosOnlyProvider = StateNotifierProvider<MusicVideosOnlyNotifier, bool>((ref) {
  return MusicVideosOnlyNotifier();
});

class MusicVideosOnlyNotifier extends StateNotifier<bool> {
  static const String _boxName = 'settings';
  static const String _key = 'musicVideosOnly';
  Box? _box;

  MusicVideosOnlyNotifier() : super(false) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _box = await Hive.openBox(_boxName);
    state = _box?.get(_key, defaultValue: false) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    await _box?.put(_key, state);
  }

  Future<void> setValue(bool value) async {
    state = value;
    await _box?.put(_key, state);
  }
}