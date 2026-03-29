import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;
  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await dioClient.dio.get('/notifications');
      final list = res.data as List;
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('Không tải được thông báo');
    }
  }
}
