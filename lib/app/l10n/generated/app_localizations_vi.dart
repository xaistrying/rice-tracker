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

  @override
  String get allTime => 'Tất cả';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get customRange => 'Tùy chọn';

  @override
  String get selectDateRange => 'Chọn khoảng thời gian';

  @override
  String get noPurchaserInPeriodTitle => 'Không có dữ liệu';

  @override
  String get noPurchaserInPeriodDescription =>
      'Không có ai được thêm trong khoảng thời gian đã chọn. Hãy thử khoảng khác hoặc xóa bộ lọc.';

  @override
  String get noSearchResultTitle => 'Không tìm thấy tên';

  @override
  String get noSearchResultDescription =>
      'Không có ai khớp với từ khóa bạn nhập. Hãy kiểm tra lại chính tả hoặc xóa từ khóa để xem tất cả.';

  @override
  String get storeUnreadableTitle => 'Không mở được dữ liệu đã lưu';

  @override
  String get storeUnreadableDescription =>
      'Dữ liệu chưa bị xóa và đã được giữ lại một bản sao. Hãy sao lưu thiết bị và nhờ hỗ trợ trước khi thêm dữ liệu mới.';

  @override
  String storePartialTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Không đọc được $count mục',
    );
    return '$_temp0';
  }

  @override
  String get storePartialDescription =>
      'Những mục còn lại vẫn hiển thị bên dưới, nên tổng khối lượng đang thấp hơn thực tế. Một bản sao của dữ liệu gốc đã được giữ lại.';

  @override
  String get dismiss => 'Đóng';

  @override
  String get reportTitle => 'Báo cáo giao lúa';

  @override
  String get reportPurchaser => 'Người giao dịch';

  @override
  String get reportDate => 'Ngày ghi nhận';

  @override
  String get reportNo => 'STT';

  @override
  String get reportTotal => 'Tổng cộng';

  @override
  String get reportBags => 'Số bao nhận';
}
