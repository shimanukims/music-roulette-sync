import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'genre_roulette_screen.dart';
import 'mood_dj_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const GenreRouletteScreen(),
    const MoodDJScreen(),
    const FavoritesScreen(),
    const HistoryScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.casino_outlined),
      selectedIcon: Icon(Icons.casino),
      label: 'ルーレット',
    ),
    NavigationDestination(
      icon: Icon(Icons.mood_outlined),
      selectedIcon: Icon(Icons.mood),
      label: 'ムードDJ',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_outline),
      selectedIcon: Icon(Icons.favorite),
      label: 'お気に入り',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: '履歴',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final musicVideosOnly = ref.watch(musicVideosOnlyProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Roulette'),
        actions: [
          // Music Videos Only Toggle
          Row(
            children: [
              const Text('MVのみ'),
              Switch(
                value: musicVideosOnly,
                onChanged: (_) {
                  ref.read(musicVideosOnlyProvider.notifier).toggle();
                },
              ),
            ],
          ),
          // Theme Toggle
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            tooltip: 'テーマ切り替え',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}