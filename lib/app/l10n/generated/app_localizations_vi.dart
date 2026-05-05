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
  String get editName => 'Thay đổi tên';

  @override
  String get enterNewNameDialogDescription =>
      'Nhập tên mới để thay thế tên hiện tại.';

  @override
  String get enterName => 'Nhập tên...';

  @override
  String get deleteItemTitle => 'Xóa người mua này?';

  @override
  String get deleteItemDescription =>
      'Sau khi xóa, bạn sẽ không thể khôi phục.';

  @override
  String get enterAnAmount => 'Nhập khối lượng gạo...';

  @override
  String get bags => 'bao';

  @override
  String get bag => 'Bao';

  @override
  String get weight => 'Khối lượng';

  @override
  String get noPeopleTitle => 'Chưa có ai được thêm';

  @override
  String get noPeopleDescription =>
      'Nhấn + để thêm người đầu tiên và theo dõi lượng gạo họ đã mua.';

  @override
  String get noRiceBagTitle => 'Chưa có bao gạo nào';

  @override
  String get noRiceBagDescription =>
      'Hãy thêm bao đầu tiên để bắt đầu theo dõi.';

  @override
  String get search => 'Tìm kiếm';
}
