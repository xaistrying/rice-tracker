enum LanguageCode { en, vi }

extension LanguageCodeExtension on LanguageCode {
  String get rawValue {
    switch (this) {
      case LanguageCode.en:
        return 'English';
      case LanguageCode.vi:
        return 'Tiếng Việt';
    }
  }

  static LanguageCode fromRawValue(String raw) {
    switch (raw) {
      case 'en':
        return LanguageCode.en;
      case 'vi':
        return LanguageCode.vi;
      default:
        throw ArgumentError('Unknown language code: $raw');
    }
  }
}
