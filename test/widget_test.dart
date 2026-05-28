import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:profile_resume/main.dart';

void main() {
  testWidgets('portfolio app renders consulting landing page', (tester) async {
    await tester.pumpWidget(const PortfolioApp());
    await tester.pump();

    expect(find.text('Tech Know Trees'), findsOneWidget);
    expect(find.text('Empowering Digital Transformation'), findsOneWidget);
  });

  testWidgets('404 page returns home through go_router', (tester) async {
    final router = GoRouter(
      initialLocation: '/missing',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Text('Home route'),
          ),
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
