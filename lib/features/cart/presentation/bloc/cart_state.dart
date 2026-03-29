part of 'cart_bloc.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool containsProduct(String productId) =>
      items.any((item) => item.product.id == productId);

  @override
  List<Object?> get props => [items];
}
