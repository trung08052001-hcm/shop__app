import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
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
                              title: 'Tài khoản',
                              items: [
                                _MenuItem(
                                  icon: Icons.person_outline,
                                  label: 'Thông tin cá nhân',
                                  onTap: () => _showEditProfile(
                                    context,
                                    name: name,
                                    email: email,
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.lock_outline,
                                  label: 'Đổi mật khẩu',
                                  onTap: () => _showChangePassword(context),
                                ),
                                _MenuItem(
                                  icon: Icons.location_on_outlined,
                                  label: 'Địa chỉ giao hàng',
                                  onTap: () => _showShippingAddress(context),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildSection(
                              title: 'Đơn hàng',
                              items: [
                                _MenuItem(
                                  icon: Icons.receipt_long_outlined,
                                  label: 'Lịch sử đơn hàng',
                                  onTap: () {},
                                ),
                                _MenuItem(
                                  icon: Icons.favorite_outline,
                                  label: 'Sản phẩm yêu thích',
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
                              title: 'Khác',
                              items: [
                                _MenuItem(
                                  icon: Icons.chat_outlined,
                                  label: 'Trò chuyện với Admin',
                                  onTap: () => context.push(AppRoutes.chat),
                                ),
                                _MenuItem(
                                  icon: Icons.help_outline,
                                  label: 'Trợ giúp & Hỗ trợ',
                                  onTap: () => _showHelp(context),
                                ),

                                _MenuItem(
                                  icon: Icons.info_outline,
                                  label: 'Về ứng dụng',
                                  onTap: () => _showAbout(context),
                                ),
                              ],
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
                                      'Đăng xuất',
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
              'Thông tin cá nhân',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: emailCtrl,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email (không thể thay đổi)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật thông tin!'),
                    backgroundColor: Color(0xFF6C63FF),
                  ),
                );
              },
              child: const Text('Lưu thay đổi'),
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
              child: const Text('Đổi mật khẩu'),
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
              decoration: const InputDecoration(
                labelText: 'Thành phố',
                prefixIcon: Icon(Icons.location_city_outlined),
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
              child: const Text('Lưu địa chỉ'),
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
          'Trợ giúp & Hỗ trợ',
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
            child: const Text('Đóng'),
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
          'Về ứng dụng',
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
              'Shop App',
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
            child: const Text('Đóng'),
          ),
        ],
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
          'Bạn có chắc muốn đăng xuất không?',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Huỷ',
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
            child: Text('Đăng xuất', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
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
                        color: const Color(0xFF6C63FF).withOpacity(0.08),
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
