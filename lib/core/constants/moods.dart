class Mood {
  final String id;
  final String displayName;
  final String emoji;
  final List<String> searchKeywords;

  const Mood({
    required this.id,
    required this.displayName,
    required this.emoji,
    required this.searchKeywords,
  });
}

class Moods {
  static const List<Mood> presetMoods = [
    Mood(
      id: 'sad',
      displayName: '悲しい',
      emoji: '😢',
      searchKeywords: ['失恋ソング', 'バラード', '切ない曲', '泣ける歌'],
    ),
    Mood(
      id: 'happy',
      displayName: 'うれしい',
      emoji: '😄',
      searchKeywords: ['ハッピーソング', '元気な曲', 'アップテンポ', '楽しい歌'],
    ),
    Mood(
      id: 'relax',
      displayName: 'リラックス',
      emoji: '😌',
      searchKeywords: ['癒し音楽', 'チルアウト', 'リラックス', 'ヒーリング'],
    ),
    Mood(
      id: 'energetic',
      displayName: '元気出したい',
      emoji: '😤',
      searchKeywords: ['応援ソング', 'パワフル', '前向きな歌', 'モチベーション'],
    ),
    Mood(
      id: 'nostalgic',
      displayName: 'なつかしい',
      emoji: '🥺',
      searchKeywords: ['懐メロ', 'ノスタルジック', '懐かしい曲', '思い出の歌'],
    ),
    Mood(
      id: 'chill',
      displayName: 'まったり',
      emoji: '😎',
      searchKeywords: ['チル', 'ローファイ', 'まったり', 'カフェミュージック'],
    ),
    Mood(
      id: 'romantic',
      displayName: '恋してる',
      emoji: '🥰',
      searchKeywords: ['恋愛ソング', 'ラブソング', 'キュンキュン', '恋の歌'],
    ),
    Mood(
      id: 'angry',
      displayName: 'イライラ',
      emoji: '😠',
      searchKeywords: ['激しい曲', 'ハードロック', 'メタル', 'パンク'],
    ),
  ];

  static List<String> getMoodKeywords(String moodText) {
    // プリセットムードから検索
    final preset = presetMoods.firstWhere(
      (mood) => mood.displayName == moodText || mood.id == moodText,
      orElse: () => const Mood(
        id: 'default',
        displayName: '',
        emoji: '',
        searchKeywords: ['J-POP', '人気曲', '話題の曲'],
      ),
    );
    
    if (preset.id != 'default') {
      return preset.searchKeywords;
    }

    // カスタムテキストの場合の簡易マッピング
    final lowerText = moodText.toLowerCase();
    if (lowerText.contains('疲れ')) {
      return ['癒し音楽', 'リラックス', 'ヒーリング'];
    } else if (lowerText.contains('眠') || lowerText.contains('寝')) {
      return ['睡眠用BGM', 'オルゴール', 'ピアノ 癒し'];
    } else if (lowerText.contains('勉強') || lowerText.contains('作業')) {
      return ['作業用BGM', '集中力', 'カフェミュージック'];
    } else if (lowerText.contains('運動') || lowerText.contains('トレーニング')) {
      return ['ワークアウト', 'EDM', 'エクササイズ'];
    }
    
    // デフォルト
    return ['J-POP', '人気曲', '話題の曲'];
  }
}