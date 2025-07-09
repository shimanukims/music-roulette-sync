import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/youtube_api_service.dart';
import '../../domain/entities/video.dart';

final videoPlayerProvider = StateNotifierProvider<VideoPlayerNotifier, AsyncValue<List<Video>>>((ref) {
  return VideoPlayerNotifier();
});

class VideoPlayerNotifier extends StateNotifier<AsyncValue<List<Video>>> {
  final YouTubeApiService _youtubeService = YouTubeApiService();

  VideoPlayerNotifier() : super(const AsyncValue.data([]));

  Future<List<Video>> searchVideos(List<String> keywords, {bool musicVideosOnly = false}) async {
    try {
      // Use Future.microtask to delay state updates
      Future.microtask(() => state = const AsyncValue.loading());
      
      final videoModels = await _youtubeService.searchVideos(
        keywords,
        musicVideosOnly: musicVideosOnly,
      );
      final videos = videoModels.map((model) => model.toEntity()).toList();
      
      Future.microtask(() => state = AsyncValue.data(videos));
      return videos;
    } catch (e) {
      Future.microtask(() => state = AsyncValue.error(e, StackTrace.current));
      rethrow;
    }
  }
}