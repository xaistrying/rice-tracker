// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Sổ Lúa';

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
      'Nhập tên người bạn muốn theo dõi số lúa';

  @override
  String get editName => 'Thay đổi tên';

  @override
  String get enterNewNameDialogDescription =>
      'Nhập tên mới để thay thế tên hiện tại.';

  @override
  String get enterName => 'Nhập tên...';

  @override
  String get deleteItemTitle => 'Xóa người giao dịch này?';

  @override
  String get deleteItemDescription =>
      'Sau khi xóa, bạn sẽ không thể khôi phục.';

  @override
  String get enterAnAmount => 'Nhập khối lượng bao...';

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
      'Nhấn + để thêm người đầu tiên và theo dõi lượng bao lúa họ đã giao dịch.';

  @override
  String get noRiceBagTitle => 'Chưa có bao lúa nào';

  @override
  String get noRiceBagDescription =>
      'Hãy thêm bao đầu tiên để bắt đầu theo dõi.';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get warning => 'Cảnh báo';

  @override
  String get warningRiceAmountDescription =>
      'Khối lượng phải nằm trong khoảng từ 0 đến 1000.';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get deleteAllPurchaser => 'Xóa toàn bộ người giao dịch';

  @override
  String get deleteAllPurchaserDialogDescription =>
      'Thao tác này sẽ xóa vĩnh viễn toàn bộ dữ liệu người giao dịch và không thể khôi phục.';

  @override
  String get deleteAllPurchaserConfirmHinText => 'Nhập DELETE để xác nhận';
}
