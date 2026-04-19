import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shop_app/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_app/l10n/app_localizations.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/bloc/locale_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<CartBloc>()),
          BlocProvider.value(value: getIt<WishlistBloc>()..add(LoadWishlist())),
          BlocProvider.value(value: getIt<LocaleBloc>()..add(LoadStoredLocale())),
          BlocProvider.value(value: getIt<AuthBloc>()..add(GetCurrentUserRequested())),
        ],
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp.router(
              title: 'Shop App',
              theme: AppTheme.light,
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
              locale: localeState.locale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
