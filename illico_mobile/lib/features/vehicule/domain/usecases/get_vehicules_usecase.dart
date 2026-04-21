import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vehicule_entity.dart';
import '../repositories/vehicule_repository.dart';

class GetVehiculesUseCase {
  final VehiculeRepository repository;
  GetVehiculesUseCase(this.repository);
  Future<Either<Failure, List<VehiculeEntity>>> execute({bool? actif}) => repository.getAll(actif: actif);
}
