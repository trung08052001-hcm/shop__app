import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      address: params.address,
      phone: params.phone,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String address;
  final String phone;

  const UpdateProfileParams({
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [address, phone];
}
