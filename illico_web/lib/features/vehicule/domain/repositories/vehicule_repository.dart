import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vehicule_entity.dart';
abstract class VehiculeRepository {
  Future<Either<Failure, List<VehiculeEntity>>> getAll({bool? actif});
  Future<Either<Failure, VehiculeEntity>> getById(String id);
  Future<Either<Failure, VehiculeEntity>> create(Map<String, dynamic> body);
  Future<Either<Failure, VehiculeEntity>> update(String id, Map<String, dynamic> body);
  Future<Either<Failure, void>> delete(String id);
}
