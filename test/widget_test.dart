import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:profile_resume/main.dart';

void main() {
  testWidgets('not found page returns home without throwing', (tester) async {
    final router = GoRouter(
      initialLocation: '/missing',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Home'),
          ),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundPage(),
    );

    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Page Not Found'), findsOneWidget);

    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
  });
}
