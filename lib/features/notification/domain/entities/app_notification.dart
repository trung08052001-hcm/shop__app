import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final int? discount;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.discount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
