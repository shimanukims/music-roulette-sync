// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:music_roulette_sync/main.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    Hive.init('.');
  });

  tearDownAll(() async {
    // Clean up Hive
    await Hive.deleteFromDisk();
  });

  testWidgets('Music Roulette app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MusicRouletteApp()));

    // Wait for the app to finish loading
    await tester.pumpAndSettle();

    // Verify that the app loads with navigation bar
    expect(find.text('ルーレット'), findsOneWidget);
    expect(find.text('ムードDJ'), findsOneWidget);
    expect(find.text('お気に入り'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
  });
}
