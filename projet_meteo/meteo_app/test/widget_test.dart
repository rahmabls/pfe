import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_app/main.dart'; // ← vérifie que "meteo_app" est bien le nom de ton projet

void main() {
  testWidgets('L’application se lance et affiche HomeScreen', (
    WidgetTester tester,
  ) async {
    // Lancer l’application
    await tester.pumpWidget(const MyApp());

    // Attendre que l’interface se stabilise
    await tester.pumpAndSettle();

    // Vérifier qu’on a bien un Scaffold (donc un écran affiché)
    expect(find.byType(Scaffold), findsOneWidget);

    // Vérifier que ta ville apparaît bien
    expect(find.text("Beni Mellal, Maroc"), findsOneWidget);
  });
}
