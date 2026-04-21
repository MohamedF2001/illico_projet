import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/livraison_entity.dart';
import '../../domain/repositories/livraison_repository.dart';
import '../datasources/livraison_remote_datasource.dart';

class LivraisonRepositoryImpl implements LivraisonRepository {
  final LivraisonRemoteDataSource _ds;
  LivraisonRepositoryImpl(this._ds);
  @override Future<Either<Failure, Map<String, dynamic>>> estimatePrice(Map<String, dynamic> body) => _ds.estimatePrice(body);
  @override Future<Either<Failure, LivraisonEntity>> create(Map<String, dynamic> body) => _ds.create(body);
  @override Future<Either<Failure, List<LivraisonEntity>>> getAll({Map<String, dynamic>? filters}) async { final r = await _ds.getAll(filters: filters); return r.map((l) => l.cast<LivraisonEntity>()); }
  @override Future<Either<Failure, LivraisonEntity>> getById(String id) => _ds.getById(id);
  @override Future<Either<Failure, Map<String, dynamic>>> validateOtp(String id, String otp) => _ds.validateOtp(id, otp);
  @override Future<Either<Failure, void>> delete(String id) => _ds.delete(id);
  @override Future<Either<Failure, LivraisonEntity>> updateStatut(String id, String statut) => _ds.updateStatut(id, statut);
  @override Future<Either<Failure, LivraisonEntity>> assignLivreur(String id, String livreurId) => _ds.assignLivreur(id, livreurId);
  @override Future<Either<Failure, Map<String, dynamic>>> uploadPreuve(String id, dynamic file, bool isWeb) => _ds.uploadPreuve(id, file, isWeb);
}
