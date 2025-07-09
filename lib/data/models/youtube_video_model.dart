import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/video.dart';

part 'youtube_video_model.freezed.dart';
part 'youtube_video_model.g.dart';

@freezed
class YouTubeVideoModel with _$YouTubeVideoModel {
  const YouTubeVideoModel._();
  
  const factory YouTubeVideoModel({
    required String id,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required String duration,
    required String publishedAt,
    String? description,
  }) = _YouTubeVideoModel;

  factory YouTubeVideoModel.fromJson(Map<String, dynamic> json) =>
      _$YouTubeVideoModelFromJson(json);

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      channelTitle: channelTitle,
      thumbnailUrl: thumbnailUrl,
      duration: _parseDuration(duration),
      publishedAt: DateTime.parse(publishedAt),
      description: description,
    );
  }

  static Duration _parseDuration(String duration) {
    // YouTube API returns duration in ISO 8601 format (PT#M#S)
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    
    if (match == null) return Duration.zero;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}