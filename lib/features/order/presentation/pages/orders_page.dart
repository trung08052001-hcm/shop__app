import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../bloc/order_bloc.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin {
  late final OrderBloc _bloc;

  @override
  bool get wantKeepAlive => false; // false = luôn rebuild khi quay lại tab

  @override
  void initState() {
    super.initState();
    _bloc = getIt<OrderBloc>()..add(LoadMyOrders());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Đơn hàng của tôi',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
              onPressed: () => _bloc.add(LoadMyOrders()),
            ),
          ],
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              );
            }
            if (state is OrderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadMyOrders()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is OrderListLoaded) {
              if (state.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80.sp,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF6C63FF),
                onRefresh: () async => _bloc.add(LoadMyOrders()),
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.orders.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => _OrderCard(order: state.orders[i]),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final order;
  const _OrderCard({required this.order});

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.receipt_outlined,
                    color: const Color(0xFF6C63FF),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn #${order.id.substring(order.id.length - 6).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade100),

          // Items preview
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              children: [
                ...order.items
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF1A1A2E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order.items.length > 2)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+ ${order.items.length - 2} sản phẩm khác',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade100),

          // Footer: tổng tiền
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} sản phẩm',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Text(
                  '${_formatPrice(order.totalPrice)}đ',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      'pending': ('Chờ xử lý', const Color(0xFFF59E0B)),
      'processing': ('Đang xử lý', const Color(0xFF3B82F6)),
      'shipped': ('Đang giao', const Color(0xFF8B5CF6)),
      'delivered': ('Đã giao', const Color(0xFF10B981)),
      'cancelled': ('Đã huỷ', const Color(0xFFEF4444)),
    };
    final entry = map[status] ?? ('Không xác định', Colors.grey);
    final label = entry.$1;
    final color = entry.$2;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
