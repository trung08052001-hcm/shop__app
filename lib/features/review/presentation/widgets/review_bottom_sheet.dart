import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../order/domain/entities/order.dart';
import '../bloc/review_bloc.dart';

class ReviewBottomSheet extends StatelessWidget {
  final AppOrder order;

  const ReviewBottomSheet({super.key, required this.order});

  static void show(BuildContext context, AppOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<ReviewBloc>(),
        child: ReviewBottomSheet(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đánh giá đơn hàng',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              shrinkWrap: true,
              itemCount: order.items.length,
              separatorBuilder: (_, __) => Divider(height: 32.h),
              itemBuilder: (context, index) {
                return _ReviewItemWidget(item: order.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItemWidget extends StatefulWidget {
  final OrderItem item;

  const _ReviewItemWidget({required this.item});

  @override
  State<_ReviewItemWidget> createState() => _ReviewItemWidgetState();
}

class _ReviewItemWidgetState extends State<_ReviewItemWidget> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmittedSuccess) {
          if (state.review.productId == widget.item.productId) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gửi đánh giá thành công!')),
            );
            Navigator.pop(context);
          }
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ReviewSubmitLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.item.image,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 50.w,
                      height: 50.w,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Chất lượng sản phẩm',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 32.sp,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _commentController,
              enabled: !isLoading,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Hãy chia sẻ nhận xét của bạn về sản phẩm...',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<ReviewBloc>().add(
                              SubmitReviewEvent(
                                productId: widget.item.productId,
                                rating: _rating,
                                comment: _commentController.text.trim(),
                              ),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'HOÀN THÀNH',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
