// Project imports:
import 'purchaser_model.dart';

/// One table row: the span of bag numbers it covers, and their weights.
///
/// [weights] always holds one entry per column, padded with empty strings on
/// the last row so the columns line up.
typedef ReportRow = ({int first, int last, List<String> weights});

/// What a shared report shows, arranged for a chat-sized image.
///
/// Kept apart from the widget that draws it so the arithmetic and the layout
/// decisions can be checked without rendering anything.
class PurchaserReport {
  PurchaserReport(this.purchaser, {this.perRow = 5});

  final PurchaserModel purchaser;

  /// How many bags share a row.
  ///
  /// One per row would make a hundred bags a ribbon roughly 1200x6000, which a
  /// chat shows as an unreadable sliver until it is opened. Five keeps even a
  /// large report near page-shaped.
  final int perRow;

  String get name => (purchaser.name ?? '').trim();

  /// The 'dd/MM/yyyy HH:mm' the purchaser was added, as stored.
  String get dateAdded => purchaser.dateAdded ?? '';

  int get quantity => purchaser.quantity;

  double get totalWeight => purchaser.totalWeight;

  /// Each bag's weight to one decimal, in the order they were added.
  List<String> get weights => [
    for (final bag in purchaser.listOfRiceBagWeights ?? const [])
      (bag.weight ?? 0).toStringAsFixed(1),
  ];

  /// The bags in [perRow]-sized rows, in the order they were added.
  ///
  /// Straight across then down, so the numbers read the way they are written
  /// and each row is labelled by the span it covers rather than repeating a
  /// number against every weight.
  List<ReportRow> get weightRows {
    final all = weights;

    if (all.isEmpty) return const [];

    final rows = <ReportRow>[];

    for (var start = 0; start < all.length; start += perRow) {
      final end = start + perRow < all.length ? start + perRow : all.length;

      rows.add((
        first: start + 1,
        last: end,
        weights: [
          for (var i = start; i < start + perRow; i++)
            i < all.length ? all[i] : '',
        ],
      ));
    }

    return rows;
  }

  /// '1 - 5', or just '21' where a row holds a single bag.
  String rangeLabel(ReportRow row) =>
      row.first == row.last ? '${row.first}' : '${row.first} - ${row.last}';
}
