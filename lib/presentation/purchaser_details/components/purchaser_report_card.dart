// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../app/extension/context_extension.dart';
import '../../../app/theme/app_color.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../domain/models/purchaser_report.dart';

/// The report as it is rendered into the shared image.
///
/// Laid out at [width] logical pixels and captured at a higher pixel ratio, so
/// this is sized for a chat bubble rather than for the screen it is built on.
class PurchaserReportCard extends StatelessWidget {
  const PurchaserReportCard({
    super.key,
    required this.report,
    this.width = 480,
  });

  final PurchaserReport report;
  final double width;

  static const _rowHeight = 18.0;
  static const _cellFontSize = 11.0;

  /// Wide enough for the longest span a three-digit bag count produces,
  /// '96 - 100'.
  static const rangeWidth = 58.0;

  /// Every other row is tinted, so the eye can follow one across the table.
  static const _stripe = AppColor.secondary;

  @override
  Widget build(BuildContext context) {
    final rows = report.weightRows;

    return Container(
      width: width,
      color: AppColor.white,
      padding: const EdgeInsets.all(AppDimens.padding20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.loc.appTitle,
            style: const TextStyle(
              fontSize: AppDimens.fontSizeDefault,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
              height: 1.2,
            ),
          ),
          Text(
            context.loc.reportTitle,
            style: const TextStyle(
              fontSize: AppDimens.fontSizeDefault,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppDimens.padding16),

          _Field(label: context.loc.reportPurchaser, value: report.name),
          _Field(label: context.loc.reportDate, value: report.dateAdded),
          _Field(label: context.loc.reportBags, value: '${report.quantity}'),

          const SizedBox(height: AppDimens.padding12),

          if (rows.isNotEmpty) ...[
            const _HeaderRow(),
            for (var i = 0; i < rows.length; i++)
              Container(
                height: _rowHeight,
                color: i.isEven ? AppColor.white : _stripe,
                child: Row(
                  children: [
                    _RangeCell(
                      label: report.rangeLabel(rows[i]),
                      style: _cellStyle(AppColor.foreground),
                    ),
                    for (final weight in rows[i].weights)
                      Expanded(
                        child: Text(
                          weight,
                          textAlign: TextAlign.right,
                          style: _cellStyle(AppColor.foreground),
                        ),
                      ),
                  ],
                ),
              ),
          ],

          // The result, set apart the way a grand total is: a rule above it,
          // and a second one below to close the report off.
          Container(
            margin: const EdgeInsets.only(top: AppDimens.padding4),
            padding: const EdgeInsets.symmetric(vertical: AppDimens.padding8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColor.foreground, width: 1.4),
                bottom: BorderSide(color: AppColor.foreground, width: 1.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.loc.reportTotal,
                  style: const TextStyle(
                    fontSize: AppDimens.fontSizeSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                Text(
                  '${report.totalWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: AppDimens.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle _cellStyle(Color color) => TextStyle(
    fontSize: _cellFontSize,
    color: color,
    // Digits share one width, so the columns stay straight.
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// A 'Label : value' line, with the colons aligned down the block.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeSmall,
                fontWeight: FontWeight.bold,
                color: AppColor.black,
              ),
            ),
          ),
          const Text(
            ':  ',
            style: TextStyle(
              fontSize: AppDimens.fontSizeSmall,
              color: AppColor.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppDimens.fontSizeSmall,
                color: AppColor.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The row-span label, ruled off from the weights beside it.
class _RangeCell extends StatelessWidget {
  const _RangeCell({
    required this.label,
    required this.style,
    this.onDark = false,
  });

  final String label;
  final TextStyle style;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PurchaserReportCard.rangeWidth,
      height: double.infinity,
      padding: const EdgeInsets.only(right: AppDimens.padding8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: onDark ? AppColor.white : AppColor.border,
            width: 1,
          ),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(label, maxLines: 1, style: style),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: PurchaserReportCard._cellFontSize,
      fontWeight: FontWeight.bold,
      color: AppColor.white,
    );

    return Container(
      // Padded rather than a fixed height: the Vietnamese header is longer
      // than the English, and a fixed height clipped its descenders.
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding4),
      color: AppColor.foreground,
      child: IntrinsicHeight(
        child: Row(
          children: [
            _RangeCell(label: context.loc.reportNo, style: style, onDark: true),
            // Spans the weight columns rather than repeating over each one.
            Expanded(
              child: Text(
                '${context.loc.weight} (kg)',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
