import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/core/network/dio_client.dart';
import 'package:shop_app/features/cart/datasources/coupon_remote_datasource.dart';
import '../services/google_auth_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register SharedPreferences trước (vì DioClient cần nó)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.init();
  if (!getIt.isRegistered<CouponRemoteDataSource>()) {
    getIt.registerFactory<CouponRemoteDataSource>(
      () => CouponRemoteDataSourceImpl(getIt<DioClient>()),
    );
  }
  // GoogleAuthService isn't in generated config, register manually
  if (!getIt.isRegistered<GoogleAuthService>()) {
    getIt.registerSingleton<GoogleAuthService>(
      GoogleAuthService(getIt<DioClient>()),
    );
  }
}
