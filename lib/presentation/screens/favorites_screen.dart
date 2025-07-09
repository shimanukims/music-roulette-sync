import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/favorites_provider.dart';
import '../widgets/video_list_item.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
        centerTitle: true,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _showClearConfirmDialog(context, ref),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'お気に入りがありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '動画再生画面でお気に入りボタンを押してください',
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
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                return VideoListItem(
                  videoId: favorite.videoId,
                  title: favorite.title,
                  channelTitle: favorite.channelTitle,
                  thumbnailUrl: favorite.thumbnailUrl,
                  subtitle: _formatDate(favorite.addedAt),
                  onTap: () => _playVideo(context, favorite.videoId),
                  onDelete: () => _removeFavorite(context, ref, favorite.videoId),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日前に追加';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前に追加';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前に追加';
    } else {
      return 'たった今追加';
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

  void _removeFavorite(BuildContext context, WidgetRef ref, String videoId) {
    ref.read(favoritesProvider.notifier).removeFromFavorites(videoId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('お気に入りから削除しました')),
    );
  }

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('すべてのお気に入りを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('すべてのお気に入りを削除しました')),
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
              child: Text('お気に入りの動画を再生中'),
            ),
          ),
        ],
      ),
    );
  }
}