import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override Future<Either<Failure, Map<String, dynamic>>> loginAdmin({required String email, required String motDePasse}) => _ds.loginAdmin(email: email, motDePasse: motDePasse);
  @override Future<Either<Failure, Map<String, dynamic>>> loginClient({required String telephone, required String codePin}) => _ds.loginClient(telephone: telephone, codePin: codePin);
  @override Future<Either<Failure, Map<String, dynamic>>> loginLivreur({required String telephone, required String motDePasse}) => _ds.loginLivreur(telephone: telephone, motDePasse: motDePasse);
  @override Future<Either<Failure, Map<String, dynamic>>> loginPoint({required String telephone, required String motDePasse}) => _ds.loginPoint(telephone: telephone, motDePasse: motDePasse);
  @override Future<Either<Failure, Map<String, dynamic>>> initClientRegister({required String telephone}) => _ds.initClientRegister(telephone: telephone);
  @override Future<Either<Failure, UserEntity>> registerClient({required Map<String, dynamic> body}) async { final r = await _ds.registerClient(body); return r.map((m) => m.toEntity()); }
  @override Future<Either<Failure, UserEntity>> registerLivreur({required Map<String, dynamic> body}) async { final r = await _ds.registerLivreur(body); return r.map((m) => m.toEntity()); }
  @override Future<Either<Failure, UserEntity>> registerAdmin({required Map<String, dynamic> body}) async { final r = await _ds.registerAdmin(body); return r.map((m) => m.toEntity()); }
  @override Future<Either<Failure, UserEntity>> registerPoint({required Map<String, dynamic> body}) async { final r = await _ds.registerPoint(body); return r.map((m) => m.toEntity()); }
  @override Future<Either<Failure, UserEntity>> getProfile() async { final r = await _ds.getProfile(); return r.map((m) => m.toEntity()); }
  @override Future<Either<Failure, String>> uploadProfilePhoto({required dynamic fileData, bool isWeb = false}) => _ds.uploadProfilePhoto(fileData, isWeb);
}
