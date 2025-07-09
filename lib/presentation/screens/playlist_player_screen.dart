import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/video.dart';
import '../providers/favorites_provider.dart';
import '../providers/play_history_provider.dart';
import '../widgets/loading_indicator.dart';

class PlaylistPlayerScreen extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistPlayerScreen({
    super.key,
    required this.playlist,
  });

  @override
  ConsumerState<PlaylistPlayerScreen> createState() => _PlaylistPlayerScreenState();
}

class _PlaylistPlayerScreenState extends ConsumerState<PlaylistPlayerScreen> {
  YoutubePlayerController? _controller;
  int _currentVideoIndex = 0;
  final bool _isAutoPlay = true;
  bool _isRepeat = false;
  bool _isShuffle = false;
  List<int> _shuffleOrder = [];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    if (widget.playlist.videos.isEmpty) return;

    final video = widget.playlist.videos[_currentVideoIndex];
    _controller?.dispose();
    
    _controller = YoutubePlayerController(
      initialVideoId: video.id,
      flags: YoutubePlayerFlags(
        autoPlay: _isAutoPlay,
        mute: false,
        enableCaption: false,
      ),
    );

    _controller!.addListener(() {
      if (_controller!.value.playerState == PlayerState.ended) {
        _playNext();
      }
    });

    // Add to play history
    ref.read(playHistoryProvider.notifier).addToHistory(
      video,
      genreId: widget.playlist.genreId,
      mood: widget.playlist.mood,
    );
  }

  void _playNext() {
    if (widget.playlist.videos.isEmpty) return;

    if (_isShuffle) {
      if (_shuffleOrder.isEmpty) {
        _shuffleOrder = List.generate(widget.playlist.videos.length, (i) => i);
        _shuffleOrder.shuffle();
      }
      
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentVideoIndex);
      final nextShuffleIndex = (currentShuffleIndex + 1) % _shuffleOrder.length;
      
      if (nextShuffleIndex == 0 && !_isRepeat) {
        // End of shuffled playlist
        return;
      }
      
      setState(() {
        _currentVideoIndex = _shuffleOrder[nextShuffleIndex];
      });
    } else {
      final nextIndex = (_currentVideoIndex + 1) % widget.playlist.videos.length;
      
      if (nextIndex == 0 && !_isRepeat) {
        // End of playlist
        return;
      }
      
      setState(() {
        _currentVideoIndex = nextIndex;
      });
    }
    
    _initializePlayer();
  }

  void _playPrevious() {
    if (widget.playlist.videos.isEmpty) return;

    if (_isShuffle) {
      if (_shuffleOrder.isEmpty) return;
      
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentVideoIndex);
      final previousShuffleIndex = (currentShuffleIndex - 1 + _shuffleOrder.length) % _shuffleOrder.length;
      
      setState(() {
        _currentVideoIndex = _shuffleOrder[previousShuffleIndex];
      });
    } else {
      setState(() {
        _currentVideoIndex = (_currentVideoIndex - 1 + widget.playlist.videos.length) % widget.playlist.videos.length;
      });
    }
    
    _initializePlayer();
  }

  void _addToFavorites() {
    if (widget.playlist.videos.isEmpty) return;
    
    final video = widget.playlist.videos[_currentVideoIndex];
    ref.read(favoritesProvider.notifier).addToFavorites(video);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('お気に入りに追加しました')),
    );
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
      if (_isShuffle) {
        _shuffleOrder = List.generate(widget.playlist.videos.length, (i) => i);
        _shuffleOrder.shuffle();
      } else {
        _shuffleOrder.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playlist.videos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.playlist.title),
        ),
        body: const Center(
          child: Text('プレイリストに動画がありません'),
        ),
      );
    }

    final currentVideo = widget.playlist.videos[_currentVideoIndex];
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: isLandscape ? null : AppBar(
        title: Text(widget.playlist.title),
        actions: [
          IconButton(
            icon: Icon(_isShuffle ? Icons.shuffle : Icons.shuffle_outlined),
            onPressed: _toggleShuffle,
            tooltip: 'シャッフル',
          ),
          IconButton(
            icon: Icon(_isRepeat ? Icons.repeat : Icons.repeat_outlined),
            onPressed: () => setState(() => _isRepeat = !_isRepeat),
            tooltip: 'リピート',
          ),
        ],
      ),
      body: SafeArea(
        child: _controller == null
            ? const LoadingIndicator()
            : _buildPlayer(context, currentVideo, isLandscape),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, Video video, bool isLandscape) {
    if (isLandscape) {
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.primary,
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
                      Icons.playlist_play,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentVideoIndex + 1} / ${widget.playlist.videos.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
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
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _playPrevious,
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 32,
                    ),
                    IconButton(
                      onPressed: () => _controller?.value.isPlaying == true
                          ? _controller?.pause()
                          : _controller?.play(),
                      icon: Icon(_controller?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow),
                      iconSize: 48,
                    ),
                    IconButton(
                      onPressed: _playNext,
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addToFavorites,
                      icon: const Icon(Icons.favorite),
                      label: const Text('お気に入り'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleShuffle,
                      icon: Icon(_isShuffle ? Icons.shuffle : Icons.shuffle_outlined),
                      label: Text(_isShuffle ? 'シャッフル中' : 'シャッフル'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isRepeat = !_isRepeat),
                    icon: Icon(_isRepeat ? Icons.repeat : Icons.repeat_outlined),
                    label: Text(_isRepeat ? 'リピート中' : 'リピート'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRepeat 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
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
}