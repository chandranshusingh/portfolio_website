// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:profile_resume/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('portfolio app renders the landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioApp());

    expect(find.text('Tech Know Trees'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('not found page returns home through GoRouter', (WidgetTester tester) async {
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

    expect(find.text('Page Not Found'), findsOneWidget);

    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
