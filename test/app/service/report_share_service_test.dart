// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/app/l10n/generated/app_localizations.dart';
import 'package:rice_tracker/app/service/report_share_service.dart';
import 'package:rice_tracker/app/theme/app_theme.dart';
import 'package:rice_tracker/domain/models/bag_model.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/purchaser_report.dart';
import 'package:rice_tracker/presentation/purchaser_details/components/purchaser_report_card.dart';

/// Weights that look like a scale reading, not round numbers.
PurchaserModel purchaserWith(int bagCount, {String name = 'Trần Văn A'}) {
  var weight = 47.3;
  return PurchaserModel(
    id: '1',
    name: name,
    dateAdded: '30/08/2026 17:53',
    listOfRiceBagWeights: [
      for (var i = 0; i < bagCount; i++)
        BagModel(id: 'b$i', weight: weight += (i % 7) * 0.4 - 1.1),
    ],
  );
}

/// Captures the card and, when RICE_REPORT_OUT is set, writes it there so the
/// result can actually be looked at rather than only measured.
Future<Size> captureTo(
  WidgetTester tester,
  PurchaserModel purchaser,
  String fileName, {
  String locale = 'en',
}) async {
  Future<Uint8List>? pending;

  // l10n.yaml sets use-deferred-loading, so the bundle for this locale is
  // fetched asynchronously. Forcing it here, under real async, means the tree
  // below Localizations has something to build with on the first frame.
  await tester.runAsync(() => AppLocalizations.delegate.load(Locale(locale)));

  await tester.pumpWidget(
    MaterialApp(
      // The real theme, so the captured image uses the app's font rather than
      // the test harness's box-drawing fallback.
      theme: AppTheme.lightTheme,
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => pending = ReportShareService.capture(
            context,
            PurchaserReportCard(report: PurchaserReport(purchaser)),
          ),
          child: const Text('go'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    find.text('go'),
    findsOneWidget,
    reason: 'the $locale bundle must have loaded before anything is captured',
  );

  await tester.tap(find.text('go'));

  // The service waits on two endOfFrame futures, and in a test frames only
  // happen when they are pumped.
  await tester.pump();
  await tester.pump();

  late Size size;

  // toImage is a real engine call; it never completes on the fake async clock.
  await tester.runAsync(() async {
    final bytes = await pending!;

    final image = await decodeImageFromList(bytes);
    size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();

    final outDir = Platform.environment['RICE_REPORT_OUT'];
    if (outDir != null) {
      await File('$outDir/$fileName').writeAsBytes(bytes);
    }
  });

  await tester.pumpAndSettle();

  return size;
}

void main() {
  setUpAll(() async {
    // Without this every glyph is drawn as a filled box, which hides exactly
    // what the captured image is meant to be checked for: real text, and
    // Vietnamese marks in particular.
    final loader = FontLoader('OpenSans')
      ..addFont(
        File(
          'assets/fonts/OpenSans-VariableFont_wdth,wght.ttf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await loader.load();
  });

  group('weightRows', () {
    test('holds five bags per row and pads the last one', () {
      final rows = PurchaserReport(purchaserWith(12)).weightRows;

      expect(rows, hasLength(3));
      expect(rows.every((r) => r.weights.length == 5), isTrue);
      expect(
        rows.last.weights.where((w) => w.isEmpty),
        hasLength(3),
        reason: '12 bags leaves 3 empty cells so the columns still line up',
      );
    });

    test('is empty when there are no bags', () {
      expect(PurchaserReport(PurchaserModel(id: '1')).weightRows, isEmpty);
    });

    test('spans run across then down, matching the order bags were added', () {
      final report = PurchaserReport(purchaserWith(12));
      final rows = report.weightRows;

      expect(rows.map((r) => (r.first, r.last)), [(1, 5), (6, 10), (11, 12)]);
      expect(rows.map(report.rangeLabel), ['1 - 5', '6 - 10', '11 - 12']);
    });

    test('a row holding one bag is labelled with just that number', () {
      // '11 - 11' would read as a mistake.
      final report = PurchaserReport(purchaserWith(11));

      expect(report.rangeLabel(report.weightRows.last), '11');
    });

    test('a three-digit span still fits the label', () {
      final report = PurchaserReport(purchaserWith(100));

      expect(report.weightRows, hasLength(20));
      expect(report.rangeLabel(report.weightRows.last), '96 - 100');
    });

    test('keeps every weight, in order, to one decimal', () {
      final report = PurchaserReport(purchaserWith(7));
      final flat = report.weightRows
          .expand((r) => r.weights)
          .where((w) => w.isNotEmpty)
          .toList();

      expect(flat, report.weights);
      expect(flat, hasLength(7));
      expect(flat.every((w) => w.contains('.')), isTrue);
    });
  });

  group('fileNameFor', () {
    test('folds marks rather than stripping them', () {
      final name = ReportShareService.fileNameFor(
        PurchaserReport(purchaserWith(1, name: 'Trần Văn A')),
      );

      expect(name, 'rice-tran-van-a-30-08-2026.png');
    });

    test('survives a name that is entirely punctuation', () {
      final name = ReportShareService.fileNameFor(
        PurchaserReport(purchaserWith(1, name: '///')),
      );

      expect(name, 'rice-30-08-2026.png');
      expect(name, isNot(contains('/')), reason: 'it becomes a file path');
    });
  });

  group('capture', () {
    testWidgets('produces a PNG at the requested pixel ratio', (tester) async {
      final size = await captureTo(tester, purchaserWith(12), 'report_12.png');

      // 480 logical width at pixelRatio 3.
      expect(size.width, 1440);
      expect(size.height, greaterThan(0));
    });

    testWidgets('a hundred bags stays near page-shaped', (tester) async {
      final size = await captureTo(
        tester,
        purchaserWith(100),
        'report_100.png',
      );

      expect(size.width, 1440);
      // The whole point of the five columns: a single list would be a ribbon
      // roughly 1080x6000, which a chat shows as an unreadable sliver.
      expect(
        size.height / size.width,
        lessThan(3),
        reason: 'a very tall image previews as a thin strip in a chat bubble',
      );
    });

    testWidgets('the Vietnamese labels fit their column', (tester) async {
      // They are all longer than the English, and the label column is a fixed
      // width, so this is where the header block would overflow first.
      await captureTo(tester, purchaserWith(12), 'report_vi.png', locale: 'vi');

      expect(tester.takeException(), isNull);
    });

    testWidgets('a report taller than the screen is not clipped', (
      tester,
    ) async {
      final short = await captureTo(tester, purchaserWith(5), 'report_5.png');
      final long = await captureTo(tester, purchaserWith(100), 'report_b.png');

      // The test surface is 800 logical pixels tall. Capturing off-screen is
      // what lifts that limit; inside a viewport this would cap out.
      expect(long.height, greaterThan(short.height * 2));
      expect(long.height, greaterThan(short.height));
    });
  });
}
