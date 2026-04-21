import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> loginAdmin({required String email, required String motDePasse});
  Future<Either<Failure, Map<String, dynamic>>> loginClient({required String telephone, required String codePin});
  Future<Either<Failure, Map<String, dynamic>>> loginLivreur({required String telephone, required String motDePasse});
  Future<Either<Failure, Map<String, dynamic>>> loginPoint({required String telephone, required String motDePasse});
  Future<Either<Failure, Map<String, dynamic>>> initClientRegister({required String telephone});
  Future<Either<Failure, UserEntity>> registerClient({required Map<String, dynamic> body});
  Future<Either<Failure, UserEntity>> registerLivreur({required Map<String, dynamic> body});
  Future<Either<Failure, UserEntity>> registerAdmin({required Map<String, dynamic> body});
  Future<Either<Failure, UserEntity>> registerPoint({required Map<String, dynamic> body});
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, String>> uploadProfilePhoto({required dynamic fileData, bool isWeb = false});
}
