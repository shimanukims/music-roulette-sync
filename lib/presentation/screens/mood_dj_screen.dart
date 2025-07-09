import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/moods.dart';
import 'video_player_screen.dart';

class MoodDJScreen extends ConsumerStatefulWidget {
  const MoodDJScreen({super.key});

  @override
  ConsumerState<MoodDJScreen> createState() => _MoodDJScreenState();
}

class _MoodDJScreenState extends ConsumerState<MoodDJScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedMood;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _searchByMood(String mood) {
    if (mood.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          genre: null,
          mood: mood,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ムードDJ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLandscape
              ? Row(
                  children: [
                    Expanded(
                      child: _buildMoodSelection(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCustomInput(context),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMoodSelection(context),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: _buildCustomInput(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMoodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '気分を選択してください',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: Moods.presetMoods.length,
            itemBuilder: (context, index) {
              final mood = Moods.presetMoods[index];
              final isSelected = _selectedMood == mood.id;
              
              return Card(
                elevation: isSelected ? 8 : 2,
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood.id;
                    });
                    _searchByMood(mood.displayName);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomInput(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'または自由に入力',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '例: 恋愛で落ち込んでる、勉強に集中したい',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 2,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchByMood(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      _searchByMood(text);
                    }
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('音楽を探す'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}