// Dart imports:
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../domain/models/purchaser_model.dart';
import '../extension/string_extension.dart';
import '../../domain/models/purchaser_report.dart';
import '../../presentation/purchaser_details/components/purchaser_report_card.dart';

class ReportShareService {
  ReportShareService._();

  /// Renders [child] where nobody can see it and returns it as a PNG.
  ///
  /// The widget is mounted in the overlay rather than drawn onto a canvas by
  /// hand, so it keeps the app's fonts and text layout — Vietnamese included —
  /// and can be previewed on screen with the very same code.
  static Future<Uint8List> capture(
    BuildContext context,
    Widget child, {
    double pixelRatio = 3,
  }) async {
    final boundaryKey = GlobalKey();
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        // Off the left edge rather than Offstage, which does not paint at all
        // — and toImage can only return what was painted. Positioning it out
        // of view also lifts the height limit the viewport would impose, so a
        // report taller than the screen is captured whole.
        left: -10000,
        top: 0,
        child: RepaintBoundary(
          key: boundaryKey,
          // Text outside a Material has no default style to inherit.
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );

    overlay.insert(entry);

    try {
      // Inserting only schedules a frame; the first await reaches the end of
      // it and the second lets the entry lay out and paint.
      //
      // Deliberately not the widely posted `while (boundary.debugNeedsPaint)`
      // loop: in a release build that getter's late field is never assigned
      // and reading it throws.
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: pixelRatio);

      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      entry.remove();
    }
  }

  /// Builds the report for [purchaser] and hands it to the system share sheet.
  static Future<void> sharePurchaserReport(
    BuildContext context,
    PurchaserModel purchaser,
  ) async {
    final report = PurchaserReport(purchaser);

    final bytes = await capture(context, PurchaserReportCard(report: report));

    // systemTemp is the app's own cache directory on Android, which share_plus
    // already exposes through its file provider, so no extra dependency and
    // no storage permission.
    final file = File('${Directory.systemTemp.path}/${fileNameFor(report)}');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  /// A file name built from the purchaser, so a saved report says whose it is.
  ///
  /// Everything outside a small safe set is replaced, because the name is free
  /// text and reaches a file path from here. Marks are folded rather than
  /// stripped, so 'Trần Văn A' gives 'tran-van-a' and not 'tr-n-v-n-a'.
  static String fileNameFor(PurchaserReport report) {
    final slug = report.name.foldedForSearch
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    final day = report.dateAdded.split(' ').first.replaceAll('/', '-');

    final parts = [
      'rice',
      if (slug.isNotEmpty) slug,
      if (day.isNotEmpty) day,
    ].join('-').replaceAll(RegExp(r'-{2,}'), '-');

    return '$parts.png';
  }
}
