// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shop App';

  @override
  String hello(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get shopToday => 'Let\'s shop today!';

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get featured => 'Featured';

  @override
  String get allProducts => 'All Products';

  @override
  String get seeAll => 'See All';

  @override
  String get retry => 'Retry';

  @override
  String get viewNow => 'View Now';

  @override
  String get account => 'Account';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get orders => 'Orders';

  @override
  String get orderHistory => 'Order History';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get others => 'Others';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chatWithAdmin => 'Chat with Admin';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get aboutApp => 'About App';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get name => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Login';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get or => 'or';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get googleLoginFailed => 'Google login failed, please try again!';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get recruitment => 'Recruitment';
}
