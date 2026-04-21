import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/livraison_repository.dart';
class EstimatePriceUseCase {
  final LivraisonRepository repository;
  EstimatePriceUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> execute(Map<String, dynamic> body) => repository.estimatePrice(body);
}
