import 'package:go_router/go_router.dart';
import 'package:shop_app/core/widget/main_scaffold.dart';
import 'package:shop_app/features/wishlist/presentation/wishlist_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/recruitment/presentation/pages/recruitment_page.dart';

import 'package:shop_app/features/cart/presentation/pages/cart_page.dart';
import 'package:shop_app/features/order/presentation/pages/orders_page.dart';
import 'package:shop_app/features/profile/presentation/page/profile_page.dart';

part 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.product,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailPage(productId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.wishlist,
      builder: (context, state) => const WishlistPage(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: AppRoutes.recruitment,
      builder: (context, state) => const RecruitmentPage(),
    ),
  ],
);
