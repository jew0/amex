import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amex/main.dart'; // Assure-toi que le nom du package 'amex' correspond à ton pubspec.yaml

void main() {
  testWidgets('Test de l\'interface bancaire et navigation', (WidgetTester tester) async {
    // 1. Charger l'application NanoBank.
    await tester.pumpWidget(const NanoBank());

    // 2. Vérifier que le message de bienvenue s'affiche avec le nom par défaut.
    // On utilise findsOneWidget car "Jean Dupont" doit être présent sur l'accueil.
    expect(find.textContaining('Jean Dupont'), findsOneWidget);

    // 3. Vérifier que le solde initial est bien affiché.
    expect(find.textContaining('2450.50 €'), findsOneWidget);

    // 4. Tester la navigation : Cliquer sur l'icône Réglages dans la barre de navigation.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle(); // Attendre que l'animation de transition soit finie

    // 5. Vérifier que nous sommes bien sur la page Réglages.
    expect(find.text('Réglages'), findsOneWidget);
    
    // 6. Vérifier que le bouton "Custom" est présent.
    expect(find.textContaining('Custom (Admin Mode)'), findsOneWidget);
  });

  testWidgets('Test de la présence des transactions', (WidgetTester tester) async {
    await tester.pumpWidget(const NanoBank());

    // Vérifier qu'une transaction spécifique est listée (ex: Apple Store).
    expect(find.text('Apple Store'), findsOneWidget);
    expect(find.textContaining('-129.0 €'), findsOneWidget);
  });
}