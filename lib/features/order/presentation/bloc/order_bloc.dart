import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';

part 'order_event.dart';
part 'order_state.dart';

@injectable
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;

  OrderBloc({required this.createOrderUseCase, required this.getOrdersUseCase})
    : super(OrderInitial()) {
    on<CreateOrder>(_onCreateOrder);
    on<LoadMyOrders>(_onLoadMyOrders);
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await createOrderUseCase(
      CreateOrderParams(items: event.items, totalPrice: event.totalPrice),
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onLoadMyOrders(
    LoadMyOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await getOrdersUseCase(NoParams());
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (orders) => emit(OrderListLoaded(orders)),
    );
  }
}
