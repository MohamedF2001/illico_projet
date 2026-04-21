import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/livraison_entity.dart';

abstract class LivraisonRepository {
  Future<Either<Failure, Map<String, dynamic>>> estimatePrice(Map<String, dynamic> body);
  Future<Either<Failure, LivraisonEntity>> create(Map<String, dynamic> body);
  Future<Either<Failure, List<LivraisonEntity>>> getAll({Map<String, dynamic>? filters});
  Future<Either<Failure, LivraisonEntity>> getById(String id);
  Future<Either<Failure, Map<String, dynamic>>> validateOtp(String id, String otp);
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, LivraisonEntity>> updateStatut(String id, String statut);
  Future<Either<Failure, LivraisonEntity>> assignLivreur(String id, String livreurId);
  Future<Either<Failure, Map<String, dynamic>>> uploadPreuve(String id, dynamic file, bool isWeb);
}
