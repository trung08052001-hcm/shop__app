import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/order.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

double _toDouble(dynamic value) => (value as num).toDouble();

// Xử lý product là String hoặc Object từ populate()
String _productIdFromJson(dynamic value) {
  if (value is String) return value;
  if (value is Map<String, dynamic>) return value['_id'] as String;
  return '';
}

@freezed
class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    // Thêm fromJson vào đây — đây là chỗ bị thiếu!
    @JsonKey(name: 'product', fromJson: _productIdFromJson)
    required String productId,
    required String name,
    required String image,
    @JsonKey(fromJson: _toDouble) required double price,
    required int quantity,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    @JsonKey(name: '_id') required String id,
    required List<OrderItemModel> items,
    @JsonKey(fromJson: _toDouble) required double totalPrice,
    @Default('pending') String status,
    required DateTime createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

extension OrderModelX on OrderModel {
  AppOrder toEntity() => AppOrder(
    id: id,
    items: items
        .map(
          (e) => OrderItem(
            productId: e.productId,
            name: e.name,
            image: e.image,
            price: e.price,
            quantity: e.quantity,
          ),
        )
        .toList(),
    totalPrice: totalPrice,
    status: status,
    createdAt: createdAt,
  );
}
