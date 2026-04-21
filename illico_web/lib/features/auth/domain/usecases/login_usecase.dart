import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String role,
    String? email, String? telephone, String? motDePasse, String? codePin,
  }) {
    return switch (role) {
      'Admin'       => repository.loginAdmin(email: email!, motDePasse: motDePasse!),
      'Client'      => repository.loginClient(telephone: telephone!, codePin: codePin!),
      'Livreur'     => repository.loginLivreur(telephone: telephone!, motDePasse: motDePasse!),
      'PointIllico' => repository.loginPoint(telephone: telephone!, motDePasse: motDePasse!),
      _             => Left<Failure, Map<String, dynamic>>(const Failure.unexpectedError()).future,
    };
  }
}

extension _FutureLeft<L, R> on Left<L, R> {
  Future<Either<L, R>> get future => Future.value(this);
}
