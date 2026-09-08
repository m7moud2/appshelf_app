import 'package:flutter_test/flutter_test.dart';

import 'package:appshelf_app/main.dart';

void main() {
  testWidgets('App boots to splash / store brand', (tester) async {
    await tester.pumpWidget(const AppShelfBootstrap());
    await tester.pump();
    expect(find.textContaining('رف التطبيقات'), findsWidgets);
    // Clear splash timer + bootstrap futures so the binding can tear down cleanly.
    await tester.pump(const Duration(seconds: 2));
  });
}
