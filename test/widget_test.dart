import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internme/data/models/internship_model.dart';
import 'package:internme/features/marketplace/widgets/internship_card.dart';

void main() {
  testWidgets('InternshipCard renders title, company name and stipend', (WidgetTester tester) async {
    final internship = InternshipModel(
      id: 'test_card_01',
      title: 'Mobile Engineer Intern',
      companyName: 'Acme Systems',
      location: 'Remote',
      stipend: 25000,
      trustScore: 98.0,
      isVerified: true,
      description: 'Build Flutter mobile applications.',
      skills: ['Flutter', 'Dart'],
      deadline: DateTime.now().add(const Duration(days: 30)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InternshipCard(internship: internship),
        ),
      ),
    );

    expect(find.text('Mobile Engineer Intern'), findsOneWidget);
    expect(find.text('Acme Systems'), findsOneWidget);
    expect(find.text('₹25000/mo'), findsOneWidget);
    expect(find.text('98% Trust Score'), findsOneWidget);
  });
}
