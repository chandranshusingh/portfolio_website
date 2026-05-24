import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:profile_resume/main.dart';

void main() {
  testWidgets('404 page home button navigates with GoRouter', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/missing',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Home Page'),
          ),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundPage(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Page Not Found'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Go to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home Page'), findsOneWidget);
  });
}
