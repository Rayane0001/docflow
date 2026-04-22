// @author Rayane Rousseau
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:docflow/main.dart';
import 'package:docflow/providers/theme_provider.dart';

void main() {
  testWidgets('DocFlowApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const DocFlowApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
