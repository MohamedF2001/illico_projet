import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String role,
    required Map<String, dynamic> body,
  }) {
    return switch (role) {
      'Client'      => repository.registerClient(body: body),
      'Livreur'     => repository.registerLivreur(body: body),
      'Admin'       => repository.registerAdmin(body: body),
      'PointIllico' => repository.registerPoint(body: body),
      _             => Left<Failure, UserEntity>(const Failure.unexpectedError()).future,
    };
  }
}

extension _FutureLeft<L, R> on Left<L, R> {
  Future<Either<L, R>> get future => Future.value(this);
}
