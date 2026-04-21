import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id, nom: nom, role: role, telephone: telephone, email: email,
    typeClient: typeClient, adresse: adresse, soldeIllico: soldeIllico,
    forfaitActif: forfaitActif, vehicule: vehicule, statut: statut,
    scoreNote: scoreNote, cashCollecte: cashCollecte, cashReverse: cashReverse,
    valide: valide, photoProfil: photoProfil, actif: actif,
    commissionTotal: commissionTotal, location: location,
  );
}

extension UserEntityMapper on UserEntity {
  UserModel toModel() => UserModel(
    id: id, nom: nom, role: role, telephone: telephone, email: email,
    typeClient: typeClient, adresse: adresse, soldeIllico: soldeIllico,
    forfaitActif: forfaitActif, vehicule: vehicule, statut: statut,
    scoreNote: scoreNote, cashCollecte: cashCollecte, cashReverse: cashReverse,
    valide: valide, photoProfil: photoProfil, actif: actif,
    commissionTotal: commissionTotal, location: location,
  );
}
