import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shop_app/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:shop_app/core/bloc/locale_bloc.dart';
import 'package:shop_app/features/auth/presentation/bloc/auth_bloc.dart';

class AppBlocProviders {
  static get providers => [
    BlocProvider<CartBloc>.value(value: getIt<CartBloc>()),
    BlocProvider<WishlistBloc>.value(value: getIt<WishlistBloc>()..add(LoadWishlist())),
    BlocProvider<LocaleBloc>.value(value: getIt<LocaleBloc>()..add(LoadStoredLocale())),
    BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()..add(GetCurrentUserRequested())),
  ];
}
