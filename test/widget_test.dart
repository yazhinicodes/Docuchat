import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docuchat/main.dart';

void main() {
  testWidgets('shows greeting and adds a sent message', (tester) async {
    // Build the app in a fake test environment (no phone needed)
    await tester.pumpWidget(const DocuChatApp());

    // The greeting bubble should be on screen
    expect(find.text("Hi! I'm DocuChat. Ask me anything."), findsOneWidget);

    // Type a message and tap the send button
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump(); // redraw once after the tap

    // The user's bubble should now appear
    expect(find.text('Hello'), findsOneWidget);

    // Let the 1-second fake reply and the scroll animation finish
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}