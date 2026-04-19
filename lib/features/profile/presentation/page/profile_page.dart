import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/bloc/locale_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(GetCurrentUserRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            context.go(AppRoutes.login);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final name = state is AuthSuccess ? state.user.name : '...';
              final email = state is AuthSuccess ? state.user.email : '...';

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 32.h,
                          horizontal: 20.w,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            _buildSection(
                              context,
                              title: AppLocalizations.of(context)!.account,
                              items: [
                                _MenuItem(
                                  icon: Icons.person_outline,
                                  label: AppLocalizations.of(context)!.personalInfo,
                                  onTap: () => _showEditProfile(
                                    context,
                                    name: name,
                                    email: email,
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.lock_outline,
                                  label: AppLocalizations.of(context)!.changePassword,
                                  onTap: () => _showChangePassword(context),
                                ),
                                _MenuItem(
                                  icon: Icons.location_on_outlined,
                                  label: AppLocalizations.of(context)!.shippingAddress,
                                  onTap: () => _showShippingAddress(context),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildSection(
                              context,
                              title: AppLocalizations.of(context)!.orders,
                              items: [
                                _MenuItem(
                                  icon: Icons.receipt_long_outlined,
                                  label: AppLocalizations.of(context)!.orderHistory,
                                  onTap: () {},
                                ),
                                _MenuItem(
                                  icon: Icons.favorite_outline,
                                  label: AppLocalizations.of(context)!.wishlist,
                                  onTap: () {
                                    context.read<WishlistBloc>().add(
                                      LoadWishlist(),
                                    );
                                    context.push(AppRoutes.wishlist);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildSection(
                              context,
                              title: AppLocalizations.of(context)!.others,
                              items: [
                                _MenuItem(
                                  icon: Icons.language,
                                  label: AppLocalizations.of(context)!.language,
                                  onTap: () => _showLanguageSettings(context),
                                ),
                                _MenuItem(
                                  icon: Icons.chat_outlined,
                                  label: AppLocalizations.of(context)!.chatWithAdmin,
                                  onTap: () => context.push(AppRoutes.chat),
                                ),
                                _MenuItem(
                                  icon: Icons.help_outline,
                                  label: AppLocalizations.of(context)!.helpSupport,
                                  onTap: () => _showHelp(context),
                                ),
                                _MenuItem(
                                  icon: Icons.work_outline,
                                  label: AppLocalizations.of(context)!.recruitment,
                                  onTap: () => context.push(AppRoutes.recruitment),
                                ),
                                _MenuItem(
                                  icon: Icons.info_outline,
                                  label: AppLocalizations.of(context)!.aboutApp,
                                  onTap: () => _showAbout(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Logout
                      GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.red.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppLocalizations.of(context)!.logout,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEditProfile(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.personalInfo,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: emailCtrl,
              enabled: false,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context)!.email} (không thể thay đổi)',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.save),
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mật khẩu xác nhận không khớp!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đổi mật khẩu thành công!'),
                    backgroundColor: Color(0xFF6C63FF),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.changePassword),
            ),
          ],
        ),
      ),
    );
  }

  void _showShippingAddress(BuildContext context) {
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Địa chỉ giao hàng',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: cityCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.city,
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu địa chỉ giao hàng!'),
                    backgroundColor: Color(0xFF6C63FF),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppLocalizations.of(context)!.helpSupport,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📧 Email: support@shopapp.com',
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            Text('📞 Hotline: 1800-1234', style: TextStyle(fontSize: 13.sp)),
            SizedBox(height: 8.h),
            Text(
              '🕐 Giờ làm việc: 8:00 - 22:00',
              style: TextStyle(fontSize: 13.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppLocalizations.of(context)!.aboutApp,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: const Color(0xFF6C63FF),
              child: Icon(Icons.shopping_bag, color: Colors.white, size: 30.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              'Phiên bản 1.0.0',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ứng dụng mua sắm được xây dựng với Flutter & Node.js',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
              title: const Text('Tiếng Việt'),
              trailing: AppLocalizations.of(context)!.localeName == 'vi'
                  ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                  : null,
              onTap: () {
                context.read<LocaleBloc>().add(const ChangeLocale('vi'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: AppLocalizations.of(context)!.localeName == 'en'
                  ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                  : null,
              onTap: () {
                context.read<LocaleBloc>().add(const ChangeLocale('en'));
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Đăng xuất',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.confirmLogout,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: Size(80.w, 36.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.logout,
                style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: Color(0xFF6C63FF).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        item.icon,
                        size: 18.sp,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 18.sp,
                      color: Colors.grey.shade400,
                    ),
                    onTap: item.onTap,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 68.w,
                      color: Colors.grey.shade100,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
