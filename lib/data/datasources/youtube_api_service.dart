import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/youtube_video_model.dart';

class YouTubeApiService {
  late final Dio _dio;
  late final String _apiKey;
  
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const int _maxResults = 20;
  static const String _maxDuration = 'medium'; // Videos under 20 minutes

  YouTubeApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  }

  Future<List<YouTubeVideoModel>> searchVideos(
    List<String> keywords, {
    int maxResults = _maxResults,
    bool musicVideosOnly = false,
  }) async {
    try {
      // Combine keywords for search
      // Add "MV" or "Music Video" to search query if music videos only
      final query = musicVideosOnly 
          ? '${keywords.join(' ')} MV OR ${keywords.join(' ')} "Music Video" OR ${keywords.join(' ')} "ミュージックビデオ"'
          : keywords.join(' ');
      
      // Search for videos
      final searchResponse = await _dio.get(
        '/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'videoDuration': _maxDuration,
          'maxResults': maxResults,
          'regionCode': 'JP',
          'relevanceLanguage': 'ja',
          'videoCategoryId': musicVideosOnly ? '10' : null, // 10 is Music category
          'key': _apiKey,
        }..removeWhere((key, value) => value == null),
      );

      final videoIds = (searchResponse.data['items'] as List)
          .map((item) => item['id']['videoId'] as String)
          .toList();

      if (videoIds.isEmpty) return [];

      // Get video details including duration
      final detailsResponse = await _dio.get(
        '/videos',
        queryParameters: {
          'part': 'snippet,contentDetails',
          'id': videoIds.join(','),
          'key': _apiKey,
        },
      );

      final videos = (detailsResponse.data['items'] as List)
          .map((item) => YouTubeVideoModel(
                id: item['id'],
                title: item['snippet']['title'],
                channelTitle: item['snippet']['channelTitle'],
                thumbnailUrl: item['snippet']['thumbnails']['high']['url'],
                duration: item['contentDetails']['duration'],
                publishedAt: item['snippet']['publishedAt'],
                description: item['snippet']['description'],
              ))
          .where((video) {
            // Filter videos longer than 10 minutes
            final duration = video.toEntity().duration;
            return duration.inMinutes <= 10;
          })
          .toList();

      return videos;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('YouTube API制限に達しました');
      } else if (e.type == DioExceptionType.connectionError ||
                 e.type == DioExceptionType.connectionTimeout) {
        throw Exception('ネットワークエラーが発生しました');
      } else {
        throw Exception('動画の検索に失敗しました: ${e.message}');
      }
    } catch (e) {
      throw Exception('予期しないエラーが発生しました: $e');
    }
  }
}