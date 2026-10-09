import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalikoot/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('KaliKoot smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KaliKootApp());
    expect(find.text('KALIKOOT'), findsOneWidget);
  });
}
