import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/play_history.dart';
import '../../core/constants/genres.dart';
import '../providers/play_history_provider.dart';
import '../widgets/video_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(playHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('再生履歴'),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearConfirmDialog(context, ref),
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '再生履歴がありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ルーレットやムードDJで音楽を再生してください',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return VideoListItem(
                  videoId: item.videoId,
                  title: item.title,
                  channelTitle: item.channelTitle,
                  thumbnailUrl: item.thumbnailUrl,
                  subtitle: _buildSubtitle(item),
                  onTap: () => _playVideo(context, item.videoId),
                  onDelete: () => _removeFromHistory(context, ref, item.id),
                );
              },
            ),
    );
  }

  String _buildSubtitle(PlayHistory item) {
    final parts = <String>[];
    
    if (item.genreId != null) {
      final genre = Genres.allGenres.firstWhere(
        (g) => g.id == item.genreId,
        orElse: () => Genres.allGenres.first,
      );
      parts.add('ジャンル: ${genre.displayName}');
    }
    
    if (item.mood != null) {
      parts.add('ムード: ${item.mood}');
    }
    
    parts.add(_formatDate(item.playedAt));
    
    return parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  void _playVideo(BuildContext context, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VideoPlayerPage(videoId: videoId),
      ),
    );
  }

  void _removeFromHistory(BuildContext context, WidgetRef ref, String historyId) {
    ref.read(playHistoryProvider.notifier).removeFromHistory(historyId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴から削除しました')),
    );
  }

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('すべての再生履歴を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(playHistoryProvider.notifier).clearAllHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('すべての履歴を削除しました')),
              );
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerPage extends StatefulWidget {
  final String videoId;

  const _VideoPlayerPage({required this.videoId});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('動画再生'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('履歴の動画を再生中'),
            ),
          ),
        ],
      ),
    );
  }
}