/// The Vietnamese letters that fold onto each base letter when searching.
///
/// Written as base -> variants rather than as two parallel strings so the two
/// sides cannot silently drift out of alignment.
///
/// Only lowercase forms are listed; callers lowercase first, and 'Đ' (U+0110)
/// lowercases to 'đ' (U+0111) rather than to 'd', so it still needs an entry.
const _vietnameseVariants = <String, String>{
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<int, String> _foldTable = {
  for (final entry in _vietnameseVariants.entries)
    for (final rune in entry.value.runes) rune: entry.key,
};

extension SearchFolding on String {
  /// This string lowercased with Vietnamese tone and vowel marks removed.
  ///
  /// Names are stored with their marks, but a phone keyboard makes them slow
  /// to type, so a query is matched on its base letters: 'tran' has to find
  /// 'Trần'. [String.toLowerCase] alone is not enough, since it folds case but
  /// leaves 'ê' and 'đ' distinct from 'e' and 'd'.
  ///
  /// Fold both sides of a comparison, never just one.
  String get foldedForSearch {
    final lower = toLowerCase();
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      // Text is normally precomposed (ầ is the single rune U+1EA7), but a
      // decomposed source carries the mark as a separate combining rune that
      // has to be dropped rather than looked up.
      if (rune >= 0x0300 && rune <= 0x036F) continue;

      buffer.write(_foldTable[rune] ?? String.fromCharCode(rune));
    }

    return buffer.toString();
  }
}
