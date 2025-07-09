import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'dart:math';
import '../../core/constants/genres.dart';
import '../providers/roulette_animation_provider.dart';
import '../providers/playlist_provider.dart';
import 'playlist_player_screen.dart';

class GenreRouletteScreen extends ConsumerStatefulWidget {
  const GenreRouletteScreen({super.key});

  @override
  ConsumerState<GenreRouletteScreen> createState() => _GenreRouletteScreenState();
}

class _GenreRouletteScreenState extends ConsumerState<GenreRouletteScreen> {
  StreamController<int>? _controller;
  bool _isSpinning = false;
  int? _selectedIndex;

  StreamController<int> get controller {
    _controller ??= StreamController<int>.broadcast();
    return _controller!;
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _spinRoulette() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = null;
    });

    final random = Random();
    final index = random.nextInt(Genres.allGenres.length);
    
    controller.add(index);

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isSpinning = false;
        _selectedIndex = index;
      });
    });
  }

  void _playSelectedGenre() async {
    if (_selectedIndex == null) return;
    
    final selectedGenre = Genres.allGenres[_selectedIndex!];
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('${selectedGenre.displayName}のプレイリストを作成中...'),
          ],
        ),
      ),
    );

    try {
      // Create playlist for selected genre
      final playlist = await ref.read(playlistProvider.notifier).createGenrePlaylist(
        selectedGenre.id,
        selectedGenre.displayName,
        selectedGenre.searchKeywords,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to playlist player
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistPlayerScreen(playlist: playlist),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('エラー'),
            content: Text('プレイリストの作成に失敗しました\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _resetRoulette() {
    setState(() {
      _selectedIndex = null;
      _isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showAnimation = ref.watch(rouletteAnimationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ジャンルルーレット'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(showAnimation ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              ref.read(rouletteAnimationProvider.notifier).toggle();
            },
            tooltip: 'アニメーション ${showAnimation ? 'OFF' : 'ON'}',
          ),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildRouletteSection(context, colorScheme, showAnimation),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildGenreList(context),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildRouletteSection(context, colorScheme, showAnimation),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildGenreList(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRouletteSection(BuildContext context, ColorScheme colorScheme, bool showAnimation) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          if (showAnimation) ...[
            SizedBox(
              height: 300,
              width: 300,
              child: FortuneWheel(
                selected: controller.stream,
                animateFirst: false,
                items: [
                  for (final genre in Genres.allGenres)
                    FortuneItem(
                      child: Text(
                        genre.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.casino,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedIndex != null)
                      Text(
                        Genres.allGenres[_selectedIndex!].displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (_selectedIndex == null) ...[
            FilledButton.icon(
              onPressed: _isSpinning ? null : _spinRoulette,
              icon: const Icon(Icons.casino),
              label: Text(_isSpinning ? '回転中...' : 'ルーレットを回す'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ] else ...[
            Text(
              '🎉 ${Genres.allGenres[_selectedIndex!].displayName}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              Genres.allGenres[_selectedIndex!].description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _resetRoulette,
                  icon: const Icon(Icons.refresh),
                  label: const Text('もう一度回す'),
                ),
                FilledButton.icon(
                  onPressed: _playSelectedGenre,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('音楽を聴く'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildGenreList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'ジャンル一覧',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: Genres.allGenres.length,
              itemBuilder: (context, index) {
                final genre = Genres.allGenres[index];
                final isSelected = _selectedIndex == index;
                
                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      genre.displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle: Text(
                      genre.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}