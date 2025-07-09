import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/entities/video.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Favorite>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<Favorite>> {
  static const String _boxName = 'favorites';
  Box<Map>? _box;

  FavoritesNotifier() : super([]) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _box = await Hive.openBox<Map>(_boxName);
    _loadFavorites();
  }

  void _loadFavorites() {
    if (_box == null) return;

    final favorites = _box!.values
        .map((data) => Favorite.fromJson(Map<String, dynamic>.from(data)))
        .toList();

    // Sort by added date (newest first)
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    state = favorites;
  }

  Future<void> addToFavorites(Video video) async {
    if (_box == null) return;

    // Check if already exists
    final existingIndex = state.indexWhere((fav) => fav.videoId == video.id);
    if (existingIndex != -1) return;

    final favorite = Favorite(
      videoId: video.id,
      title: video.title,
      channelTitle: video.channelTitle,
      thumbnailUrl: video.thumbnailUrl,
      addedAt: DateTime.now(),
    );

    await _box!.put(video.id, favorite.toJson());
    state = [favorite, ...state];
  }

  Future<void> removeFromFavorites(String videoId) async {
    if (_box == null) return;

    await _box!.delete(videoId);
    state = state.where((fav) => fav.videoId != videoId).toList();
  }

  bool isFavorite(String videoId) {
    return state.any((fav) => fav.videoId == videoId);
  }

  Future<void> clearAllFavorites() async {
    if (_box == null) return;

    await _box!.clear();
    state = [];
  }
}