import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required Duration duration,
    required DateTime publishedAt,
    String? description,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) =>
      _$VideoFromJson(json);
}