import 'package:flutter_test/flutter_test.dart';
import 'package:za3ma_ndoubel/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoyenneApp());
    expect(find.byType(MoyenneApp), findsOneWidget);
  });
}