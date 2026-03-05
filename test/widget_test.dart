import 'package:flutter_test/flutter_test.dart';

import 'package:sticky_notes_app/main.dart';
import 'package:sticky_notes_app/screens/home_screen.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StickyNotesApp());

    // Verify that the app loads with the home screen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Paff. And it\'s noted.'), findsOneWidget);
  });
}
