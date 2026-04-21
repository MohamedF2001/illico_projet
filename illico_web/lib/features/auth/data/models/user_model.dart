import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationModel extends LocationEntity {
  @override final String type;
  @override final List<double> coordinates;
  const LocationModel({this.type = 'Point', required this.coordinates})
      : super(type: type, coordinates: coordinates);
  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserModel extends UserEntity {
  @JsonKey(name: '_id') @override final String? id;
  @override final String nom;
  @override final String role;
  @override final String? telephone;
  @override final String? email;
  @override final String? typeClient;
  @override final String? adresse;
  @override final double? soldeIllico;
  @override final dynamic forfaitActif;
  @JsonKey(fromJson: _dynamicFromJson, toJson: _dynamicToJson)
  @override final dynamic vehicule;
  @override final String? statut;
  @override final double? scoreNote;
  @override final double? cashCollecte;
  @override final double? cashReverse;
  @override final bool? valide;
  @override final String? photoProfil;
  @override final bool? actif;
  @override final double? commissionTotal;
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  @override final LocationEntity? location;

  const UserModel({
    this.id, required this.nom, required this.role,
    this.telephone, this.email, this.typeClient, this.adresse,
    this.soldeIllico, this.forfaitActif, this.vehicule,
    this.statut, this.scoreNote, this.cashCollecte, this.cashReverse,
    this.valide, this.photoProfil, this.actif, this.commissionTotal, this.location,
  }) : super(id: id, nom: nom, role: role, telephone: telephone, email: email,
        typeClient: typeClient, adresse: adresse, soldeIllico: soldeIllico,
        forfaitActif: forfaitActif, vehicule: vehicule, statut: statut,
        scoreNote: scoreNote, cashCollecte: cashCollecte, cashReverse: cashReverse,
        valide: valide, photoProfil: photoProfil, actif: actif,
        commissionTotal: commissionTotal, location: location);

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static dynamic _dynamicFromJson(dynamic v) => v;
  static dynamic _dynamicToJson(dynamic v) => v is Map ? v : v?.toString();
  static LocationEntity? _locationFromJson(dynamic v) =>
      v is Map<String, dynamic> ? LocationModel.fromJson(v) : null;
  static dynamic _locationToJson(LocationEntity? v) =>
      v is LocationModel ? v.toJson() : null;
}
