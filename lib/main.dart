import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => BlocProvider(
        create: (_) => getIt<CartBloc>(),
        child: MaterialApp.router(
          title: 'Shop App',
          theme: AppTheme.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
