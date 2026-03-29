part of 'wishlist_bloc.dart';

class WishlistState extends Equatable {
  final List<Product> products;
  final Set<String> ids;

  const WishlistState({this.products = const [], this.ids = const {}});

  bool isWishlisted(String productId) => ids.contains(productId);

  @override
  List<Object?> get props => [products, ids];
}
