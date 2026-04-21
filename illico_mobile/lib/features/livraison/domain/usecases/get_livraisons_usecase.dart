import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/livraison_entity.dart';
import '../repositories/livraison_repository.dart';
class GetLivraisonsUseCase {
  final LivraisonRepository repository;
  GetLivraisonsUseCase(this.repository);
  Future<Either<Failure, List<LivraisonEntity>>> execute({Map<String, dynamic>? filters}) => repository.getAll(filters: filters);
}
