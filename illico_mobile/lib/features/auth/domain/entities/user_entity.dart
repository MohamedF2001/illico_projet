import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String type;
  final List<double> coordinates; // [longitude, latitude]
  const LocationEntity({this.type = 'Point', required this.coordinates});
  @override List<Object?> get props => [coordinates];
}

class UserEntity extends Equatable {
  final String? id;
  final String nom;
  final String? telephone;
  final String? email;
  final String role;
  // Client
  final String? typeClient;
  final String? adresse;
  final double? soldeIllico;
  final dynamic forfaitActif;
  // Livreur
  final dynamic vehicule;
  final String? statut;
  final double? scoreNote;
  final double? cashCollecte;
  final double? cashReverse;
  final bool? valide;
  final String? photoProfil;
  // PointIllico
  final bool? actif;
  final double? commissionTotal;
  // GPS
  final LocationEntity? location;

  const UserEntity({
    this.id, required this.nom, this.telephone, this.email, required this.role,
    this.typeClient, this.adresse, this.soldeIllico, this.forfaitActif,
    this.vehicule, this.statut, this.scoreNote, this.cashCollecte, this.cashReverse,
    this.valide, this.photoProfil, this.actif, this.commissionTotal, this.location,
  });

  double get cashSolde => (cashCollecte ?? 0) - (cashReverse ?? 0);
  bool get estBloque => cashSolde > 50000;

  @override
  List<Object?> get props => [id, nom, telephone, email, role];
}
