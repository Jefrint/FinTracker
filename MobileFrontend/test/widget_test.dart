import 'package:fintracker_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the FinTracker app shell', (tester) async {
    await tester.pumpWidget(const FinTrackerApp());
    await tester.pump();

    expect(find.text('FinTracker'), findsOneWidget);
  });
}
