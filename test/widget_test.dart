import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:profile_resume/main.dart';

void main() {
  testWidgets('Portfolio app renders the consulting landing page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PortfolioApp());

    expect(find.textContaining('Consulting'), findsWidgets);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('NotFoundPage returns home through GoRouter', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/missing',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home route')),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundPage(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Page Not Found'), findsOneWidget);

    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
  });
}
