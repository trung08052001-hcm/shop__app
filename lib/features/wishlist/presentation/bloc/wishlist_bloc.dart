import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/features/product/domain/entities/product.dart';
import '../../../../core/services/wishlist_service.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

@singleton
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistService wishlistService;

  WishlistBloc(this.wishlistService) : super(const WishlistState()) {
    on<LoadWishlist>(_onLoad);
    on<ToggleWishlist>(_onToggle);
  }

  Future<void> _onLoad(LoadWishlist event, Emitter<WishlistState> emit) async {
    final products = await wishlistService.getAll();
    final ids = products.map((p) => p.id).toSet();
    emit(WishlistState(products: products, ids: ids));
  }

  Future<void> _onToggle(
    ToggleWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    await wishlistService.toggle(event.product);
    final products = await wishlistService.getAll();
    final ids = products.map((p) => p.id).toSet();
    emit(WishlistState(products: products, ids: ids));
  }
}
