import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcana/models/card.dart' as game;
import 'package:arcana/models/enums.dart';
import 'package:arcana/widgets/card_widget.dart';
import 'package:arcana/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(game.Card card) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<LocalizationService>(
          create: (_) => LocalizationService(),
          child: CardWidget(card: card),
        ),
      ),
    );
  }

  testWidgets('CardWidget displays Number card correctly', (WidgetTester tester) async {
    final card = game.Card(
      type: CardType.NUMBER,
      color: CardColor.BLOOD,
      value: 10,
      id: 'blood_10',
      imageAssetPath: '',
    );

    await tester.pumpWidget(createWidgetUnderTest(card));
    await tester.pumpAndSettle();

    // Check for value and suit symbol (Heart)
    expect(find.text('10'), findsNWidgets(2)); // Top left and bottom right
    expect(find.text('♥'), findsAtLeastNWidgets(2));
  });

  testWidgets('CardWidget displays Arcanum correctly', (WidgetTester tester) async {
    final card = game.Card(
      type: CardType.ARCANUM,
      color: CardColor.NONE,
      id: 'arcanum',
      imageAssetPath: '',
    );

    await tester.pumpWidget(createWidgetUnderTest(card));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsNWidgets(2));
    expect(find.text('ARCANUM'), findsOneWidget);
    expect(find.byIcon(Icons.auto_fix_high), findsOneWidget);
  });

  testWidgets('CardWidget displays Shadow correctly', (WidgetTester tester) async {
    final card = game.Card(
      type: CardType.SHADOW,
      color: CardColor.NONE,
      id: 'shadow',
      imageAssetPath: '',
    );

    await tester.pumpWidget(createWidgetUnderTest(card));
    await tester.pumpAndSettle();

    expect(find.text('S'), findsNWidgets(2));
    expect(find.text('SHADOW'), findsOneWidget);
    expect(find.byIcon(Icons.theater_comedy), findsOneWidget);
  });
}
