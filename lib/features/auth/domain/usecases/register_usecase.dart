import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart' show UseCase;
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RegisterUseCase extends UseCase<User, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      address: params.address,
      phone: params.phone,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String address;
  final String phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.address,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, address, phone];
}
