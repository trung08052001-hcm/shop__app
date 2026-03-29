import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/features/order/domain/entities/order.dart';
import 'package:shop_app/features/order/presentation/bloc/order_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/cart_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<CartBloc>(),
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
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) {
                      final item = state.items[i];
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Ảnh
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

                            // Thông tin
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

                                  // Quantity control
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

                            // Xoá
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

                // Tổng tiền + Checkout
                _buildCheckout(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckout(BuildContext context, CartState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng (${state.totalItems} sản phẩm)',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              Text(
                '${_formatPrice(state.totalPrice)}đ',
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
                context: context,
                builder: (_) => BlocProvider(
                  create: (_) => getIt<OrderBloc>(),
                  child: BlocConsumer<OrderBloc, OrderState>(
                    listener: (context, orderState) {
                      if (orderState is OrderCreated) {
                        context.read<CartBloc>().add(ClearCart());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đặt hàng thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      if (orderState is OrderError) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(orderState.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, orderState) => AlertDialog(
                      title: const Text('Xác nhận đặt hàng'),
                      content: Text(
                        'Tổng thanh toán: ${_formatPrice(state.totalPrice)}đ',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Huỷ'),
                        ),
                        ElevatedButton(
                          onPressed: orderState is OrderLoading
                              ? null
                              : () => context.read<OrderBloc>().add(
                                  CreateOrder(
                                    items: items,
                                    totalPrice: state.totalPrice,
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

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
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
