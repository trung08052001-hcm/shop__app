import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notification_bloc.dart';

// Gọi từ bất kỳ đâu:
// NotificationSheet.show(context);
class NotificationSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<NotificationBloc>()..add(LoadNotifications()),
        child: const _NotificationSheetContent(),
      ),
    );
  }
}

class _NotificationSheetContent extends StatelessWidget {
  const _NotificationSheetContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoaded) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${state.notifications.length} mới',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  );
                }
                if (state is NotificationError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48.sp,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          state.message,
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                if (state is NotificationLoaded) {
                  if (state.notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_outlined,
                            size: 56.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Chưa có thông báo nào',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) =>
                        _NotificationCard(item: state.notifications[i]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  const _NotificationCard({required this.item});

  Color _typeColor() {
    switch (item.type) {
      case 'sale':
        return const Color(0xFFEF4444);
      case 'promotion':
        return const Color(0xFFF59E0B);
      case 'event':
        return const Color(0xFF6C63FF);
      case 'new_product':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  IconData _typeIcon() {
    switch (item.type) {
      case 'sale':
        return Icons.local_fire_department_rounded;
      case 'promotion':
        return Icons.discount_outlined;
      case 'event':
        return Icons.event_rounded;
      case 'new_product':
        return Icons.new_releases_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _typeLabel() {
    switch (item.type) {
      case 'sale':
        return 'Flash Sale';
      case 'promotion':
        return 'Khuyến mãi';
      case 'event':
        return 'Sự kiện';
      case 'new_product':
        return 'Hàng mới';
      default:
        return 'Thông báo';
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(item.createdAt);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    return '${diff.inMinutes} phút trước';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_typeIcon(), color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge + time
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        _typeLabel(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeAgo(),
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Title
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4.h),
                // Body
                Text(
                  item.body,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                // Discount badge nếu có
                if (item.discount != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Giảm ${item.discount}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
