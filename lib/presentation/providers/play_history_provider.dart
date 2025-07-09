import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/play_history.dart';
import '../../domain/entities/video.dart';

final playHistoryProvider = StateNotifierProvider<PlayHistoryNotifier, List<PlayHistory>>((ref) {
  return PlayHistoryNotifier();
});

class PlayHistoryNotifier extends StateNotifier<List<PlayHistory>> {
  static const String _boxName = 'play_history';
  Box<Map>? _box;

  PlayHistoryNotifier() : super([]) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _box = await Hive.openBox<Map>(_boxName);
    _loadHistory();
  }

  void _loadHistory() {
    if (_box == null) return;

    final history = _box!.values
        .map((data) => PlayHistory.fromJson(Map<String, dynamic>.from(data)))
        .toList();

    // Sort by played date (newest first)
    history.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    state = history;
  }

  Future<void> addToHistory(
    Video video, {
    String? genreId,
    String? mood,
  }) async {
    if (_box == null) return;

    final historyItem = PlayHistory(
      id: '${video.id}_${DateTime.now().millisecondsSinceEpoch}',
      videoId: video.id,
      title: video.title,
      channelTitle: video.channelTitle,
      thumbnailUrl: video.thumbnailUrl,
      playedAt: DateTime.now(),
      genreId: genreId,
      mood: mood,
    );

    await _box!.put(historyItem.id, historyItem.toJson());
    state = [historyItem, ...state];
  }

  Future<void> removeFromHistory(String historyId) async {
    if (_box == null) return;

    await _box!.delete(historyId);
    state = state.where((item) => item.id != historyId).toList();
  }

  Future<void> clearAllHistory() async {
    if (_box == null) return;

    await _box!.clear();
    state = [];
  }

  List<PlayHistory> getHistoryByGenre(String genreId) {
    return state.where((item) => item.genreId == genreId).toList();
  }

  List<PlayHistory> getHistoryByMood(String mood) {
    return state.where((item) => item.mood == mood).toList();
  }
}