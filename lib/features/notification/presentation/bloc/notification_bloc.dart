import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/features/notification/data/models/notification_model.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/entities/app_notification.dart';

part 'notification_event.dart';
part 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRemoteDataSource dataSource;

  NotificationBloc(this.dataSource) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final list = await dataSource.getNotifications();
      emit(NotificationLoaded(list.map((e) => e.toEntity()).toList()));
    } catch (_) {
      emit(const NotificationError('Không tải được thông báo'));
    }
  }
}
