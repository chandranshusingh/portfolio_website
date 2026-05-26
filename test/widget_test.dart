// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:profile_resume/main.dart';

void main() {
  testWidgets('404 page home button returns through GoRouter', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/missing-page',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Home page')),
          ),
        ),
      ],
      errorBuilder: (context, state) => const NotFoundPage(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Page Not Found'), findsOneWidget);

    await tester.tap(find.text('Go to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home page'), findsOneWidget);
  });
}
