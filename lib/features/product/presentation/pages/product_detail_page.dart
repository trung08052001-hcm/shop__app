import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductBloc>()..add(LoadProductDetail(productId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductError) {
              return Center(child: Text(state.message));
            }
            if (state is ProductDetailLoaded) {
              final p = state.product;
              return CustomScrollView(
                slivers: [
                  // App Bar với ảnh
                  SliverAppBar(
                    expandedHeight: 300.h,
                    pinned: true,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: p.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),

                  // Nội dung
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category tag
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.category,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Tên sản phẩm
                          Text(
                            p.name,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Rating + reviews
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                return Icon(
                                  i < p.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                              SizedBox(width: 8.w),
                              Text(
                                '${p.rating} (${p.numReviews} đánh giá)',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Giá
                          Text(
                            '${_formatPrice(p.price)}đ',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Tồn kho
                          Row(
                            children: [
                              Icon(
                                p.stock > 0
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: p.stock > 0 ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                p.stock > 0
                                    ? 'Còn ${p.stock} sản phẩm'
                                    : 'Hết hàng',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: p.stock > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          const Divider(),
                          SizedBox(height: 12.h),

                          // Mô tả
                          Text(
                            'Mô tả sản phẩm',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            p.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 100.h), // space cho button
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),

        // Nút thêm vào giỏ
        bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is! ProductDetailLoaded) return const SizedBox();
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
              child: ElevatedButton.icon(
                onPressed: state.product.stock > 0
                    ? () {
                        context.read<CartBloc>().add(AddToCart(state.product));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm vào giỏ hàng!'),
                            backgroundColor: Color(0xFF6C63FF),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Thêm vào giỏ hàng'),
              ),
            );
          },
        ),
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
