import 'package:flutter_test/flutter_test.dart';
import 'package:sticky_notes_app/injection.dart';
import 'package:sticky_notes_app/main.dart';
import 'package:sticky_notes_app/screens/home_screen.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Setup dependency injection before building the app
    setupLocator();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StickyNotesApp());
    
    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app loads with the home screen
    expect(find.byType(HomeScreen), findsOneWidget);
    // Check for AppBar with title containing "Paff"
    expect(find.textContaining('Paff'), findsOneWidget);
  });
}
