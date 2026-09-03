// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/app/widgets/tare_rate_fields.dart';
import 'package:rice_tracker/domain/models/tare_rate.dart';

void main() {
  /// Pumps the fields and records every rate they report, so a test can assert
  /// on what was never reported as well as on what was.
  Future<List<TareRate>> pumpFields(
    WidgetTester tester, {
    TareRate rate = TareRate.standard,
  }) async {
    final reported = <TareRate>[];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TareRateFields(rate: rate, onChanged: reported.add),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return reported;
  }

  Finder bagsField() => find.byType(TextFormField).first;
  Finder kgField() => find.byType(TextFormField).last;

  testWidgets('starts showing the rate it was given', (tester) async {
    await pumpFields(tester, rate: const TareRate(bags: 4, kgTenths: 5));

    expect(find.text('4'), findsOneWidget);
    expect(find.text('0.5'), findsOneWidget);
  });

  testWidgets('reports a rate once the new number is complete', (tester) async {
    final reported = await pumpFields(tester);

    await tester.enterText(bagsField(), '4');
    await tester.pump();

    expect(reported, [const TareRate(bags: 4, kgTenths: 10)]);
  });

  testWidgets('reports nothing while the bags box is empty', (tester) async {
    // The one that matters: every total on the screen divides by this box, so
    // clearing it to retype a digit must not be read as a rate of zero.
    final reported = await pumpFields(tester);

    await tester.enterText(bagsField(), '');
    await tester.pump();

    expect(reported, isEmpty);
  });

  testWidgets('reports nothing for a zero', (tester) async {
    final reported = await pumpFields(tester);

    await tester.enterText(bagsField(), '0');
    await tester.pump();

    expect(reported, isEmpty);
  });

  testWidgets('reports nothing for a half-typed decimal', (tester) async {
    // '1.' is what is on screen halfway through typing '1.5'. It must be
    // allowed to sit there without being reported or corrected.
    final reported = await pumpFields(tester);

    await tester.enterText(kgField(), '1.');
    await tester.pump();

    expect(reported, isEmpty);
    expect(find.text('1.'), findsOneWidget);
  });

  testWidgets('takes a decimal kilogram once it is complete', (tester) async {
    final reported = await pumpFields(tester);

    await tester.enterText(kgField(), '0.5');
    await tester.pump();

    expect(reported, [const TareRate(bags: 3, kgTenths: 5)]);
  });

  testWidgets('puts the rate back into a box left unusable', (tester) async {
    final reported = await pumpFields(tester);

    await tester.enterText(bagsField(), '');
    await tester.pump();

    // Focus moves away, which is where an abandoned box gets written back.
    await tester.tap(kgField());
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(
      reported,
      isEmpty,
      reason: 'restoring the text must not be reported as a change',
    );
  });

  testWidgets('refuses a second decimal point', (tester) async {
    // '1.6.6' was typeable and parses as nothing, so the box sat showing a
    // figure that was not the rate the totals were using.
    final reported = await pumpFields(tester);

    await tester.enterText(kgField(), '1.6');
    await tester.pump();
    await tester.enterText(kgField(), '1.6.6');
    await tester.pump();

    expect(find.text('1.6'), findsOneWidget);
    expect(find.text('1.6.6'), findsNothing);
    expect(reported, [const TareRate(bags: 3, kgTenths: 16)]);
  });

  testWidgets('refuses a second decimal digit', (tester) async {
    // The kilograms are stored in tenths, so a hundredth could not be kept.
    await pumpFields(tester);

    await tester.enterText(kgField(), '1.55');
    await tester.pump();

    expect(find.text('1.55'), findsNothing);
  });

  testWidgets('lets a decimal point be typed on the way to a number', (
    tester,
  ) async {
    await pumpFields(tester);

    await tester.enterText(kgField(), '1.');
    await tester.pump();

    expect(
      find.text('1.'),
      findsOneWidget,
      reason: 'rejecting this would make 1.5 impossible to type',
    );
  });

  testWidgets('does not report the rate it already has', (tester) async {
    final reported = await pumpFields(tester);

    await tester.enterText(bagsField(), '3');
    await tester.pump();

    expect(reported, isEmpty);
  });
}
