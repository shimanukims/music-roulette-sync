import 'package:freezed_annotation/freezed_annotation.dart';
import 'video.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String title,
    @JsonKey(toJson: _videosToJson) required List<Video> videos,
    required DateTime createdAt,
    String? genreId,
    String? mood,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);
}

// Helper function to convert videos list to JSON
List<Map<String, dynamic>> _videosToJson(List<Video> videos) {
  return videos.map((video) => video.toJson()).toList();
}