import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/genres.dart';
import '../../core/constants/moods.dart';
import '../../domain/entities/video.dart';
import '../providers/video_player_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/play_history_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/loading_indicator.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final MusicGenre? genre;
  final String? mood;

  const VideoPlayerScreen({
    super.key,
    this.genre,
    this.mood,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  int _currentVideoIndex = 0;
  List<Video> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final keywords = widget.genre?.searchKeywords ?? 
                      (widget.mood != null ? Moods.getMoodKeywords(widget.mood!) : []);
      final musicVideosOnly = ref.read(musicVideosOnlyProvider);
      final videos = await ref.read(videoPlayerProvider.notifier).searchVideos(
        keywords,
        musicVideosOnly: musicVideosOnly,
      );
      
      if (videos.isEmpty) {
        setState(() {
          _error = '動画が見つかりませんでした';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
      
      _initializePlayer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializePlayer() {
    if (_videos.isEmpty) return;

    final video = _videos[_currentVideoIndex];
    _controller?.dispose();
    
    _controller = YoutubePlayerController(
      initialVideoId: video.id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );

    // Add to play history
    ref.read(playHistoryProvider.notifier).addToHistory(
      video,
      genreId: widget.genre?.id,
      mood: widget.mood,
    );
  }

  void _nextVideo() {
    if (_videos.isEmpty) return;
    
    setState(() {
      _currentVideoIndex = (_currentVideoIndex + 1) % _videos.length;
    });
    _initializePlayer();
  }

  void _previousVideo() {
    if (_videos.isEmpty) return;
    
    setState(() {
      _currentVideoIndex = (_currentVideoIndex - 1 + _videos.length) % _videos.length;
    });
    _initializePlayer();
  }

  void _addToFavorites() {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentVideoIndex];
    ref.read(favoritesProvider.notifier).addToFavorites(video);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('お気に入りに追加しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: Text(widget.genre?.displayName ?? 'ムードDJ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator()
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _error!,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadVideos,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  )
                : _buildVideoPlayer(context, isLandscape),
      ),
      floatingActionButton: isLandscape ? null : _buildFloatingActionButtons(),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, bool isLandscape) {
    if (_controller == null || _videos.isEmpty) {
      return const Center(child: Text('動画を読み込み中...'));
    }

    final video = _videos[_currentVideoIndex];

    if (isLandscape) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          onReady: () {
            debugPrint('Player is ready.');
          },
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).colorScheme.primary,
            onReady: () {
              debugPrint('Player is ready.');
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  video.channelTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${video.duration.inMinutes}:${(video.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '${_currentVideoIndex + 1} / ${_videos.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _previousVideo,
                      icon: const Icon(Icons.skip_previous),
                      label: const Text('前の曲'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nextVideo,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('次の曲'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addToFavorites,
                    icon: const Icon(Icons.favorite),
                    label: const Text('お気に入りに追加'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'favorite',
          onPressed: _addToFavorites,
          child: const Icon(Icons.favorite),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'refresh',
          onPressed: _loadVideos,
          child: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}