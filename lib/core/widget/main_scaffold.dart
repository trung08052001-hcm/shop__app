import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/order/presentation/pages/orders_page.dart';
import '../../features/product/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/profile/presentation/page/profile_page.dart';
import '../router/app_router.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    ProductListPage(),
    CartPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.chat),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Tìm kiếm',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (cartState.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${cartState.totalItems}',
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
                ),
                activeIcon: const Icon(Icons.shopping_cart),
                label: 'Giỏ hàng',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Đơn hàng',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Tai khoan',
              ),
            ],
          );
        },
      ),
    );
  }
}
