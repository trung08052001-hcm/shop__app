import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/features/order/domain/entities/order.dart';
import 'package:shop_app/features/order/presentation/bloc/order_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/exceptions.dart';
import '../../datasources/coupon_remote_datasource.dart';
import 'package:shop_app/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/cart_bloc.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _customAddress;
  String? _couponCode;
  double _discountAmount = 0;
  bool _couponLoading = false;
  String? _couponError;
  String? _couponSuccess;
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CartBloc>(),
      child: BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) {
          if (previous.items.isNotEmpty && current.items.isEmpty) {
            return true;
          }

          return _couponCode != null &&
              previous.totalPrice != current.totalPrice &&
              current.items.isNotEmpty;
        },
        listener: (_, state) {
          if (state.items.isEmpty) {
            _clearCouponState(clearText: true);
            return;
          }

          _clearCouponState(
            errorMessage:
                'Giỏ hàng đã thay đổi, vui lòng áp dụng lại mã giảm giá.',
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Giỏ hàng',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            actions: [
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox();
                  return TextButton(
                    onPressed: () => context.read<CartBloc>().add(ClearCart()),
                    child: const Text(
                      'Xoá tất cả',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Giỏ hàng trống',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Mua sắm ngay'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) {
                        final item = state.items[i];
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.image,
                                  width: 80.w,
                                  height: 80.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${_formatPrice(item.product.price)}đ',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF6C63FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        _QuantityButton(
                                          icon: Icons.remove,
                                          onTap: () =>
                                              context.read<CartBloc>().add(
                                                UpdateQuantity(
                                                  productId: item.product.id,
                                                  quantity: item.quantity - 1,
                                                ),
                                              ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          '${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        _QuantityButton(
                                          icon: Icons.add,
                                          onTap: () =>
                                              context.read<CartBloc>().add(
                                                UpdateQuantity(
                                                  productId: item.product.id,
                                                  quantity: item.quantity + 1,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => context.read<CartBloc>().add(
                                  RemoveFromCart(item.product.id),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCheckout(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCheckout(BuildContext context, CartState state) {
    final payableTotal = _calculatePayableTotal(state.totalPrice);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAddressSection(context),
          SizedBox(height: 16.h),
          _buildCouponInput(context, state),
          SizedBox(height: 16.h),
          if (_discountAmount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã giảm giá ($_couponCode)',
                  style: TextStyle(fontSize: 13.sp, color: Colors.green),
                ),
                Text(
                  '- ${_formatPrice(_discountAmount)}đ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng (${state.totalItems} sản phẩm)',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              Text(
                '${_formatPrice(payableTotal)}đ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              final parentContext = context;
              final cartBloc = parentContext.read<CartBloc>();
              final messenger = ScaffoldMessenger.of(parentContext);
              final items = state.items
                  .map(
                    (e) => OrderItem(
                      productId: e.product.id,
                      name: e.product.name,
                      image: e.product.image,
                      price: e.product.price,
                      quantity: e.quantity,
                    ),
                  )
                  .toList();

              showDialog(
                context: parentContext,
                builder: (dialogContext) => BlocProvider(
                  create: (_) => getIt<OrderBloc>(),
                  child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (dialogContext, orderState) {
                      if (orderState is OrderCreated) {
                        cartBloc.add(ClearCart());
                        Navigator.pop(dialogContext);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Đặt hàng thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      if (orderState is OrderError) {
                        Navigator.pop(dialogContext);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(orderState.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (dialogContext, orderState) => AlertDialog(
                      title: const Text('Xác nhận đặt hàng'),
                      content: Text(
                        'Tổng thanh toán: ${_formatPrice(payableTotal)}đ',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Huỷ'),
                        ),
                        ElevatedButton(
                          onPressed: orderState is OrderLoading
                              ? null
                              : () => dialogContext.read<OrderBloc>().add(
                                  CreateOrder(
                                    items: items,
                                    totalPrice: payableTotal,
                                  ),
                                ),
                          child: orderState is OrderLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Đặt hàng'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: const Text('Tiến hành thanh toán'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInput(BuildContext context, CartState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: _couponLoading
                  ? null
                  : () => _applyCoupon(state.totalPrice),
              style: ElevatedButton.styleFrom(minimumSize: Size(80.w, 48.h)),
              child: _couponLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Áp dụng'),
            ),
          ],
        ),
        if (_couponError != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              _couponError!,
              style: TextStyle(fontSize: 12.sp, color: Colors.red),
            ),
          ),
        if (_couponSuccess != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              _couponSuccess!,
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
      ],
    );
  }

  Future<void> _applyCoupon(double orderTotal) async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _couponError = 'Vui lòng nhập mã giảm giá.';
        _couponSuccess = null;
      });
      return;
    }

    _couponCtrl.value = _couponCtrl.value.copyWith(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );

    setState(() {
      _couponLoading = true;
      _couponError = null;
      _couponSuccess = null;
    });

    try {
      final datasource = getIt<CouponRemoteDataSource>();
      final result = await datasource.validateCoupon(
        code: code,
        orderTotal: orderTotal,
      );

      if (!mounted) return;
      setState(() {
        _discountAmount = (result['discountAmount'] as num).toDouble();
        _couponCode = code;
        _couponSuccess = 'Giảm ${_formatPrice(_discountAmount)}đ';
      });
    } on ServerException catch (e) {
      if (!mounted) return;
      setState(() {
        _couponError = e.message;
        _discountAmount = 0;
        _couponCode = null;
      });
    } finally {
      if (mounted) {
        setState(() => _couponLoading = false);
      }
    }
  }

  double _calculatePayableTotal(double totalPrice) {
    final payableTotal = totalPrice - _discountAmount;
    return payableTotal < 0 ? 0 : payableTotal;
  }

  void _clearCouponState({bool clearText = false, String? errorMessage}) {
    if (!mounted) return;

    setState(() {
      _couponCode = null;
      _discountAmount = 0;
      _couponLoading = false;
      _couponError = errorMessage;
      _couponSuccess = null;
      if (clearText) {
        _couponCtrl.clear();
      }
    });
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userAddress = authState is AuthSuccess ? authState.user.address : '';
        final displayAddress = _customAddress ?? userAddress ?? '';

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Text(
                        'Địa chỉ nhận hàng',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showChangeAddressDialog(context, displayAddress),
                    child: Text(
                      'THAY ĐỔI',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (displayAddress.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 32.w, bottom: 8.h),
                  child: Text(
                    displayAddress,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.only(left: 32.w, bottom: 8.h),
                  child: Text(
                    'Chưa có địa chỉ nhận hàng',
                    style: TextStyle(fontSize: 13.sp, color: Colors.red),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showChangeAddressDialog(BuildContext context, String currentAddress) {
    final addressCtrl = TextEditingController(text: currentAddress);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thay đổi địa chỉ'),
        content: TextField(
          controller: addressCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập địa chỉ nhận hàng mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _customAddress = addressCtrl.text.trim();
                });
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
