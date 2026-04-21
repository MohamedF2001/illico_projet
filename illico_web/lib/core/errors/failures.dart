import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverError({String? message})                     = ServerError;
  const factory Failure.networkError()                                      = NetworkError;
  const factory Failure.unauthorized()                                      = Unauthorized;
  const factory Failure.notFound()                                          = NotFound;
  const factory Failure.validationError({required Map<String, dynamic> errors}) = ValidationError;
  const factory Failure.unexpectedError()                                   = UnexpectedError;
}

extension FailureMessage on Failure {
  String get displayMessage => when(
    serverError: (msg) => msg ?? 'Erreur serveur.',
    networkError: () => 'Vérifiez votre connexion internet.',
    unauthorized: () => 'Session expirée. Reconnectez-vous.',
    notFound: () => 'Ressource introuvable.',
    validationError: (errors) => errors.values.first?.toString() ?? 'Données invalides.',
    unexpectedError: () => 'Une erreur inattendue est survenue.',
  );
}
