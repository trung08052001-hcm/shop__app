import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    @JsonKey(name: '_id') required String id,
    required String title,
    required String body,
    required String type,
    int? discount,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

extension NotificationModelX on NotificationModel {
  AppNotification toEntity() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    discount: discount,
    createdAt: createdAt,
  );
}
