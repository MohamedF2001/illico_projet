import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/livraison_entity.dart';
import '../repositories/livraison_repository.dart';
class CreateLivraisonUseCase {
  final LivraisonRepository repository;
  CreateLivraisonUseCase(this.repository);
  Future<Either<Failure, LivraisonEntity>> execute(Map<String, dynamic> body) => repository.create(body);
}
