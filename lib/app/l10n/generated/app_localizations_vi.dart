// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Sổ Gạo';

  @override
  String get settings => 'Cài đặt';

  @override
  String get languages => 'Ngôn ngữ';

  @override
  String get close => 'Đóng';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get add => 'Thêm';

  @override
  String get grandTotal => 'Tổng khối lượng';

  @override
  String get people => 'người';

  @override
  String get name => 'Tên';

  @override
  String get enterNameDialogTitle => 'Thêm người mới';

  @override
  String get enterNameDialogDescription =>
      'Nhập tên người bạn muốn theo dõi số gạo';

  @override
  String get enterName => 'Nhập tên...';

  @override
  String get deleteItemTitle => 'Xóa người mua này?';

  @override
  String get deleteItemDescription =>
      'Sau khi xóa, bạn sẽ không thể khôi phục.';

  @override
  String get enterAnAmount => 'Nhập số khối lượng......';
}
