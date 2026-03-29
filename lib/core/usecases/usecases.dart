import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Dùng khi UseCase không cần params (vd: GetProducts)
class NoParams {}
