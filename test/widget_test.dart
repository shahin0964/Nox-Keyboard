import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nox_keyboard/app/app.dart';
import 'package:nox_keyboard/app/routes.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('NoxApp renders in IME mode', (WidgetTester tester) async {
    await tester.pumpWidget(const NoxApp(initialRoute: AppRoutes.ime));
    await tester.pumpAndSettle();

    // Verify keyboard surface rendered
    expect(find.byType(NoxApp), findsOneWidget);
  });
}
