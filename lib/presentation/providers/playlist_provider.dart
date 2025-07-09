import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/playlist.dart';
import 'video_player_provider.dart';
import 'settings_provider.dart';

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
  return PlaylistNotifier(ref);
});

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  static const String _boxName = 'playlists';
  Box<Map>? _box;
  final Ref _ref;

  PlaylistNotifier(this._ref) : super([]) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _box = await Hive.openBox<Map>(_boxName);
    _loadPlaylists();
  }

  void _loadPlaylists() {
    if (_box == null) return;

    final playlists = _box!.values
        .map((data) {
          // Ensure proper type conversion for nested maps
          final Map<String, dynamic> jsonData = {};
          (data as Map).forEach((key, value) {
            if (value is List) {
              // Convert list items to proper Map<String, dynamic>
              jsonData[key.toString()] = value.map((item) {
                if (item is Map) {
                  return Map<String, dynamic>.from(item);
                }
                return item;
              }).toList();
            } else {
              jsonData[key.toString()] = value;
            }
          });
          return Playlist.fromJson(jsonData);
        })
        .toList();

    // Sort by created date (newest first)
    playlists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = playlists;
  }

  Future<Playlist> createGenrePlaylist(String genreId, String genreName, List<String> keywords) async {
    if (_box == null) throw Exception('Database not initialized');

    try {
      // Search for videos for this genre
      final musicVideosOnly = _ref.read(musicVideosOnlyProvider);
      final videos = await _ref.read(videoPlayerProvider.notifier).searchVideos(
        keywords,
        musicVideosOnly: musicVideosOnly,
      );
      
      // Create playlist
      final playlist = Playlist(
        id: '${genreId}_${DateTime.now().millisecondsSinceEpoch}',
        title: genreName + 'のプレイリスト',
        videos: videos,
        createdAt: DateTime.now(),
        genreId: genreId,
        mood: null,
      );

      // Save to database
      // Convert to JSON and ensure all nested objects are properly serialized
      final playlistJson = playlist.toJson();
      final jsonMap = Map<String, dynamic>.from(playlistJson);
      await _box!.put(playlist.id, jsonMap);
      
      // Update state
      state = [playlist, ...state];
      
      return playlist;
    } catch (e) {
      throw Exception('プレイリストの作成に失敗しました: $e');
    }
  }

  Future<void> removePlaylist(String playlistId) async {
    if (_box == null) return;

    await _box!.delete(playlistId);
    state = state.where((playlist) => playlist.id != playlistId).toList();
  }

  Future<void> clearAllPlaylists() async {
    if (_box == null) return;

    await _box!.clear();
    state = [];
  }

  Playlist? getPlaylistById(String id) {
    try {
      return state.firstWhere((playlist) => playlist.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Playlist> getPlaylistsByGenre(String genreId) {
    return state.where((playlist) => playlist.genreId == genreId).toList();
  }
}