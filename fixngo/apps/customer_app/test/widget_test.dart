import 'package:flutter_test/flutter_test.dart';
import 'package:fix_n_go_customer/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FixNGoApp());
    await tester.pump();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
