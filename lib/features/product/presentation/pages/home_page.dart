import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:shop_app/features/notification/presentation/page/notification_sheet.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _bannerController = PageController();
  int _currentBanner = 0;
  String _userName = '';

  final _banners = [
    {
      'title': 'iPhone 15 Pro',
      'subtitle': 'Chip A17 Pro mạnh nhất',
      'color': const Color(0xFF6C63FF),
      'image': 'https://picsum.photos/seed/iphone/600/300',
    },
    {
      'title': 'MacBook Air M3',
      'subtitle': 'Siêu mỏng, siêu nhanh',
      'color': const Color(0xFF2D9CDB),
      'image': 'https://picsum.photos/seed/macbook/600/300',
    },
    {
      'title': 'Sony WH-1000XM5',
      'subtitle': 'Chống ồn đỉnh cao',
      'color': const Color(0xFF27AE60),
      'image': 'https://picsum.photos/seed/sony/600/300',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _startBannerTimer();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name') ?? 'bạn';
    });
  }

  void _startBannerTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final next = (_currentBanner + 1) % _banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _startBannerTimer();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProductBloc>()..add(const LoadProducts()),
        ),
        BlocProvider(
          create: (_) => getIt<NotificationBloc>()..add(LoadNotifications()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(child: _buildBanner()),

                  if (state is ProductLoading) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],

                  if (state is ProductListLoaded) ...[
                    SliverToBoxAdapter(
                      child: _buildCategories(context, state.categories),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSectionTitle(
                        'Nổi bật',
                        onSeeAll: () => context.read<ProductBloc>().add(
                          const LoadProducts(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFeaturedList(context, state),
                    ),
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('Tất cả sản phẩm'),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ProductCard(product: state.products[i]),
                          childCount: state.products.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  ],

                  if (state is ProductError)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Column(
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ProductBloc>()
                                    .add(const LoadProducts()),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${_firstName()} 👋',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 2.h),
              Text(
                'Mua sắm hôm nay nào!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Xoá toàn bộ BlocBuilder<CartBloc> cũ trong header
          // Thay bằng cái này:
          GestureDetector(
            onTap: () => NotificationSheet.show(context),
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final count = state is NotificationLoaded
                    ? state.notifications.length
                    : 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner carousel ─────────────────────────────────
  Widget _buildBanner() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Column(
        children: [
          SizedBox(
            height: 160.h,
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (i) => setState(() => _currentBanner = i),
              itemCount: _banners.length,
              itemBuilder: (_, i) {
                final b = _banners[i];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: b['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Ảnh bên phải
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 140.w,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: b['image'] as String,
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.15),
                            colorBlendMode: BlendMode.srcOver,
                          ),
                        ),
                      ),
                      // Text bên trái
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b['title'] as String,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              b['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Xem ngay',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: b['color'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: _currentBanner == i ? 20.w : 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: _currentBanner == i
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Categories ───────────────────────────────────────
  Widget _buildCategories(BuildContext context, List<String> categories) {
    final all = ['Tất cả', ...categories];
    final icons = [
      Icons.grid_view_rounded,
      Icons.phone_android_rounded,
      Icons.laptop_rounded,
      Icons.tablet_rounded,
      Icons.headphones_rounded,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Danh mục'),
        SizedBox(
          height: 88.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: all.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => context.read<ProductBloc>().add(
                LoadProducts(category: all[i] == 'Tất cả' ? null : all[i]),
              ),
              child: Container(
                margin: EdgeInsets.only(right: 14.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54.w,
                      height: 54.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        icons[i % icons.length],
                        color: const Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      all[i],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Featured horizontal list ─────────────────────────
  Widget _buildFeaturedList(BuildContext context, ProductListLoaded state) {
    final featured = state.products.take(6).toList();
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: featured.length,
        itemBuilder: (_, i) {
          final p = featured[i];
          return GestureDetector(
            onTap: () =>
                context.push(AppRoutes.product.replaceAll(':id', p.id)),
            child: Container(
              width: 148.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: p.image,
                      height: 120.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey[100]),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              p.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${_formatPrice(p.price)}đ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section title ────────────────────────────────────
  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────
  String _firstName() {
    if (_userName.isEmpty) return 'bạn';
    return _userName.split(' ').last;
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
