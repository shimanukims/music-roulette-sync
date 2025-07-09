class MusicGenre {
  final String id;
  final String displayName;
  final String description;
  final List<String> searchKeywords;
  final List<String> exampleArtists;

  const MusicGenre({
    required this.id,
    required this.displayName,
    required this.description,
    required this.searchKeywords,
    required this.exampleArtists,
  });
}

class Genres {
  static const List<MusicGenre> allGenres = [
    MusicGenre(
      id: 'jpop',
      displayName: '王道J-POP',
      description: 'ヒット曲／幅広い年代に人気',
      searchKeywords: ['J-POP ヒット曲', '最新邦楽', 'J-POP 人気'],
      exampleArtists: ['優里', 'スピッツ', 'いきものがかり'],
    ),
    MusicGenre(
      id: 'anime',
      displayName: 'アニソン',
      description: 'アニメ主題歌／アニメ系アーティスト',
      searchKeywords: ['アニメ主題歌', 'アニソン', 'アニメOP'],
      exampleArtists: ['LiSA', 'Aimer', 'YOASOBI'],
    ),
    MusicGenre(
      id: 'citypop',
      displayName: 'シティポップ／レトロポップ',
      description: '昭和〜令和レトロ／おしゃれ・都会的サウンド',
      searchKeywords: ['シティポップ', 'レトロポップ', '80年代 日本'],
      exampleArtists: ['松原みき', '竹内まりや', 'iri'],
    ),
    MusicGenre(
      id: 'jrock',
      displayName: '邦ロック（J-ROCK）',
      description: 'バンド系／熱い／青春感',
      searchKeywords: ['邦ロック', 'J-ROCK', '日本 ロックバンド'],
      exampleArtists: ['RADWIMPS', 'BUMP', 'マカロニえんぴつ'],
    ),
    MusicGenre(
      id: 'alternative',
      displayName: 'オルタナ／インディーロック',
      description: '実験的／個性的／音にこだわり',
      searchKeywords: ['オルタナティブロック 日本', 'インディーロック', '実験音楽'],
      exampleArtists: ['サカナクション', 'くるり', 'Cö shu Nie'],
    ),
    MusicGenre(
      id: 'visual',
      displayName: 'ヴィジュアル系ロック',
      description: 'ゴシック／激しめ／美意識強め',
      searchKeywords: ['ヴィジュアル系', 'V系', 'ビジュアル系バンド'],
      exampleArtists: ['X JAPAN', 'LUNA SEA', 'the GazettE'],
    ),
    MusicGenre(
      id: 'jrap',
      displayName: '日本語ラップ・Jヒップホップ',
      description: 'リリック重視／ビート／メッセージ性',
      searchKeywords: ['日本語ラップ', 'J-HIPHOP', '日本 ヒップホップ'],
      exampleArtists: ['Creepy Nuts', 'KEN THE 390', 'BAD HOP'],
    ),
    MusicGenre(
      id: 'jrnb',
      displayName: 'J-R&B／ネオソウル',
      description: '大人系／おしゃれ／歌唱力',
      searchKeywords: ['J-R&B', '日本 R&B', 'ネオソウル'],
      exampleArtists: ['AI', '平井堅', 'iri', 'SIRUP'],
    ),
    MusicGenre(
      id: 'jedm',
      displayName: 'ダンス・J-EDM／エレクトロポップ',
      description: 'ノリ重視／電子音／クラブサウンド',
      searchKeywords: ['J-EDM', 'エレクトロポップ', '日本 EDM'],
      exampleArtists: ['Perfume', '中田ヤスタカ', 'Yunomi'],
    ),
    MusicGenre(
      id: 'idol',
      displayName: 'アイドルポップ',
      description: 'グループ系／可愛い／元気',
      searchKeywords: ['アイドル', 'J-IDOL', '日本 アイドルグループ'],
      exampleArtists: ['乃木坂46', 'ももクロ', 'BiSH'],
    ),
    MusicGenre(
      id: 'folk',
      displayName: 'フォーク・アコースティック',
      description: '弾き語り／素朴／心にしみる',
      searchKeywords: ['フォークソング', 'アコースティック', '弾き語り'],
      exampleArtists: ['あいみょん', '秦基博', '森山直太朗'],
    ),
    MusicGenre(
      id: 'vocaloid',
      displayName: 'ネット発・ボカロ系',
      description: 'ボカロP／YouTube／ニコ動発',
      searchKeywords: ['ボカロ', 'VOCALOID', 'ボーカロイド'],
      exampleArtists: ['米津玄師', 'まふまふ', '初音ミク'],
    ),
    MusicGenre(
      id: 'warock',
      displayName: '和風・和ロック／ネオ民謡',
      description: '和楽器／和旋律×現代ビート',
      searchKeywords: ['和ロック', '和風ロック', '和楽器バンド'],
      exampleArtists: ['和楽器バンド', 'ヨルシカ', 'ずとまよ'],
    ),
    MusicGenre(
      id: 'seishun',
      displayName: '青春・恋愛ソング',
      description: '甘酸っぱい／恋愛テーマ／感情表現',
      searchKeywords: ['恋愛ソング', '青春ソング', 'ラブソング'],
      exampleArtists: ['西野カナ', '大塚愛', 'back number'],
    ),
    MusicGenre(
      id: 'soundtrack',
      displayName: 'サウンドトラック風ボーカル曲',
      description: '映画・ドラマ系／物語性／壮大な雰囲気',
      searchKeywords: ['サウンドトラック', '映画音楽', 'OST'],
      exampleArtists: ['RADWIMPS（映画曲）', 'Eve', '澤野弘之ボーカル曲'],
    ),
  ];
}