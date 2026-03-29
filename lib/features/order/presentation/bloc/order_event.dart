part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class CreateOrder extends OrderEvent {
  final List<OrderItem> items;
  final double totalPrice;

  const CreateOrder({required this.items, required this.totalPrice});

  @override
  List<Object?> get props => [items, totalPrice];
}

class LoadMyOrders extends OrderEvent {}
