import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../domain/repositories/vehicule_repository.dart';
import '../datasources/vehicule_remote_datasource.dart';

class VehiculeRepositoryImpl implements VehiculeRepository {
  final VehiculeRemoteDataSource _ds;
  VehiculeRepositoryImpl(this._ds);
  @override Future<Either<Failure, List<VehiculeEntity>>> getAll({bool? actif}) async { final r = await _ds.getAll(actif: actif); return r.map((l) => l.cast<VehiculeEntity>()); }
  @override Future<Either<Failure, VehiculeEntity>> getById(String id) => _ds.getById(id);
  @override Future<Either<Failure, VehiculeEntity>> create(Map<String, dynamic> body) => _ds.create(body);
  @override Future<Either<Failure, VehiculeEntity>> update(String id, Map<String, dynamic> body) => _ds.update(id, body);
  @override Future<Either<Failure, void>> delete(String id) => _ds.delete(id);
}
