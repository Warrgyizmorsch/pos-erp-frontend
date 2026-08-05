import 'package:flutter_test/flutter_test.dart';
import 'package:poserp/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Verify PosErpApp widget instantiates
    expect(const PosErpApp(), isNotNull);
  });
}
