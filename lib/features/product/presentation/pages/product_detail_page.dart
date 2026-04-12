//
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../bloc/product_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../review/presentation/bloc/review_bloc.dart';
import '../../../review/domain/entities/app_review.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isWishlisted = false;

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProductBloc>()..add(LoadProductDetail(widget.productId)),
        ),
        BlocProvider(
          create: (_) => getIt<ReviewBloc>()..add(LoadProductReviews(widget.productId)),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              );
            }
            if (state is ProductError) {
              return Center(child: Text(state.message));
            }
            if (state is ProductDetailLoaded) {
              final p = state.product;
              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // Hero image
                      SliverAppBar(
                        expandedHeight: 300.h,
                        pinned: true,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        leading: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _isWishlisted = !_isWishlisted,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                padding: EdgeInsets.all(6.w),
                                child: Icon(
                                  _isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: _isWishlisted
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: CachedNetworkImage(
                            imageUrl: p.image,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey.shade100),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade300,
                                size: 48.sp,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24.r),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              20.h,
                              20.w,
                              100.h,
                            ),
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
                                    color: const Color(
                                      0xFF6C63FF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    p.category,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Tên
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                // Rating + stock
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < p.rating.floor()
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: Colors.amber,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${p.rating} (${p.numReviews} đánh giá)',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),

                                // Giá + tồn kho
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_formatPrice(p.price)}đ',
                                      style: TextStyle(
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6C63FF),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.stock > 0
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: p.stock > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            p.stock > 0
                                                ? 'Còn ${p.stock} sp'
                                                : 'Hết hàng',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: p.stock > 0
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),

                                Divider(color: Colors.grey.shade100),
                                SizedBox(height: 14.h),

                                // Mô tả
                                Text(
                                  'Mô tả sản phẩm',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  p.description,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    height: 1.7,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Divider(color: Colors.grey.shade100),
                                SizedBox(height: 14.h),
                                Text(
                                  'Đánh giá sản phẩm',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                BlocBuilder<ReviewBloc, ReviewState>(
                                  builder: (context, reviewState) {
                                    if (reviewState is ReviewLoading) {
                                      return const Center(
                                          child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
                                    } else if (reviewState is ReviewError) {
                                      return Text(reviewState.message,
                                          style: const TextStyle(color: Colors.red));
                                    } else if (reviewState is ReviewLoaded) {
                                      if (reviewState.reviews.isEmpty) {
                                        return Text('Chưa có đánh giá nào',
                                            style: TextStyle(color: Colors.grey, fontSize: 13.sp));
                                      }
                                      return Column(
                                        children: reviewState.reviews
                                            .map((r) => _buildReviewCard(r))
                                            .toList(),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom bar — Add to cart
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is! ProductDetailLoaded)
                          return const SizedBox();
                        return Container(
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Wishlist button
                              GestureDetector(
                                onTap: () => setState(
                                  () => _isWishlisted = !_isWishlisted,
                                ),
                                child: Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Icon(
                                    _isWishlisted
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isWishlisted
                                        ? Colors.red
                                        : Colors.grey,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Add to cart button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: state.product.stock > 0
                                      ? () {
                                          context.read<CartBloc>().add(
                                            AddToCart(state.product),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Đã thêm vào giỏ hàng!',
                                              ),
                                              backgroundColor: const Color(
                                                0xFF6C63FF,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 48.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    state.product.stock > 0
                                        ? 'Thêm vào giỏ hàng'
                                        : 'Hết hàng',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(AppReview review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                backgroundImage: review.userAvatar != null
                    ? CachedNetworkImageProvider(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C63FF)),
                      )
                    : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  review.userName,
                  style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                ),
              ),
              Text(
                '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review.comment,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
