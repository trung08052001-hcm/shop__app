import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase extends UseCase<User, NoParams> {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
