import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submitRegister(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      RegisterSubmitted(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      ),
    );
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.go(AppRoutes.home);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(context),
                      SizedBox(height: 20.h),
                      _buildFormCard(),
                      SizedBox(height: 20.h),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9089FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: IconButton(
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Tạo tài khoản mới',
            style: TextStyle(
              fontSize: 30.sp,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Điền thông tin của bạn để bắt đầu mua sắm nhanh hơn trong ứng dụng.',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 22.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: const [
              _InfoChip(
                icon: Icons.verified_user_outlined,
                label: 'Đăng ký nhanh',
              ),
              _InfoChip(
                icon: Icons.local_shipping_outlined,
                label: 'Lưu địa chỉ giao hàng',
              ),
              _InfoChip(icon: Icons.phone_outlined, label: 'Sẵn sàng liên hệ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Hoàn tất thông tin để tạo tài khoản và lưu sẵn thông tin liên hệ của bạn.',
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 22.h),
          _buildField(
            controller: _nameCtrl,
            label: 'Họ tên',
            hint: 'Nguyễn Văn A',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                _validateRequired(value, 'Vui lòng nhập họ tên'),
          ),
          SizedBox(height: 16.h),
          _buildField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'ban@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final requiredError = _validateRequired(
                value,
                'Vui lòng nhập email',
              );
              if (requiredError != null) {
                return requiredError;
              }

              final email = value!.trim();
              if (!email.contains('@') || !email.contains('.')) {
                return 'Email không hợp lệ';
              }

              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildField(
            controller: _passwordCtrl,
            label: 'Mật khẩu',
            hint: 'Ít nhất 6 ký tự',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              final requiredError = _validateRequired(
                value,
                'Vui lòng nhập mật khẩu',
              );
              if (requiredError != null) {
                return requiredError;
              }

              if (value!.trim().length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }

              return null;
            },
          ),
          SizedBox(height: 24.h),
          Text(
            'Thông tin liên hệ',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 14.h),
          _buildField(
            controller: _phoneCtrl,
            label: 'Số điện thoại',
            hint: '0901 234 567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final requiredError = _validateRequired(
                value,
                'Vui lòng nhập số điện thoại',
              );
              if (requiredError != null) {
                return requiredError;
              }

              final phone = value!.replaceAll(RegExp(r'\s+'), '');
              if (phone.length < 9) {
                return 'Số điện thoại không hợp lệ';
              }

              return null;
            },
          ),
          SizedBox(height: 16.h),
          _buildField(
            controller: _addressCtrl,
            label: 'Địa chỉ',
            hint: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố',
            prefixIcon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            validator: (value) =>
                _validateRequired(value, 'Vui lòng nhập địa chỉ'),
          ),
          SizedBox(height: 28.h),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is AuthLoading
                    ? null
                    : () => _submitRegister(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded),
                          SizedBox(width: 10.w),
                          Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Đã có tài khoản? ',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.login),
            child: Text(
              'Đăng nhập ngay',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: Colors.white),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
