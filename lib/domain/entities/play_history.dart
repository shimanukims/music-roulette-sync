import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history.freezed.dart';
part 'play_history.g.dart';

@freezed
class PlayHistory with _$PlayHistory {
  const factory PlayHistory({
    required String id,
    required String videoId,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required DateTime playedAt,
    String? genreId,
    String? mood,
  }) = _PlayHistory;

  factory PlayHistory.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryFromJson(json);
}