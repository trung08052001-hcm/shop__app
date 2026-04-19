// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Shop App';

  @override
  String hello(String name) {
    return 'Xin chào, $name 👋';
  }

  @override
  String get shopToday => 'Mua sắm hôm nay nào!';

  @override
  String get categories => 'Danh mục';

  @override
  String get all => 'Tất cả';

  @override
  String get featured => 'Nổi bật';

  @override
  String get allProducts => 'Tất cả sản phẩm';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get retry => 'Thử lại';

  @override
  String get viewNow => 'Xem ngay';

  @override
  String get account => 'Tài khoản';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get shippingAddress => 'Địa chỉ giao hàng';

  @override
  String get orders => 'Đơn hàng';

  @override
  String get orderHistory => 'Lịch sử đơn hàng';

  @override
  String get wishlist => 'Sản phẩm yêu thích';

  @override
  String get others => 'Khác';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get chatWithAdmin => 'Trò chuyện với Admin';

  @override
  String get helpSupport => 'Trợ giúp & Hỗ trợ';

  @override
  String get aboutApp => 'Về ứng dụng';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get confirmLogout => 'Bạn có chắc muốn đăng xuất không?';

  @override
  String get cancel => 'Huỷ';

  @override
  String get close => 'Đóng';

  @override
  String get save => 'Lưu';

  @override
  String get name => 'Họ tên';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get address => 'Địa chỉ';

  @override
  String get city => 'Thành phố';

  @override
  String get login => 'Đăng nhập';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get welcomeBack => 'Chào mừng bạn quay lại!';

  @override
  String get enterEmail => 'Nhập email';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get password => 'Mật khẩu';

  @override
  String get enterPassword => 'Nhập mật khẩu';

  @override
  String get passwordTooShort => 'Ít nhất 6 ký tự';

  @override
  String get or => 'hoặc';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String get googleLoginFailed => 'Đăng nhập Google thất bại, thử lại nhé!';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? ';

  @override
  String get register => 'Đăng ký';
}
