import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/livraison_entity.dart';
part 'livraison_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PointAdresseModel extends PointAdresse {
  @override final String nomContact;
  @override final String adresse;
  @override final String telephoneContact;
  @override final List<double> coordinates;
  const PointAdresseModel({
    required this.nomContact,
    required this.adresse,
    required this.telephoneContact,
    required this.coordinates
  })
      : super(nomContact: nomContact, adresse: adresse, telephoneContact: telephoneContact, coordinates: coordinates);
  factory PointAdresseModel.fromJson(Map<String, dynamic> j) => _$PointAdresseModelFromJson(j);
  Map<String, dynamic> toJson() => _$PointAdresseModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LivraisonModel extends LivraisonEntity {
  @JsonKey(name: '_id') @override final String? id;
  @JsonKey(fromJson: _dynFromJson, toJson: _dynToJson) @override final dynamic client;
  @JsonKey(fromJson: _dynFromJson, toJson: _dynToJson) @override final dynamic livreur;
  @override final String? codeSuivi;
  @JsonKey(fromJson: _pointFromJson, toJson: _pointToJson) @override final PointAdresse pointDepart;
  @JsonKey(fromJson: _pointFromJson, toJson: _pointToJson) @override final PointAdresse pointArrivee;
  @JsonKey(fromJson: _dynFromJson, toJson: _dynToJson) @override final dynamic vehicule;
  @override final String mode;
  @JsonKey(fromJson: _dynFromJson, toJson: _dynToJson) @override final dynamic pointIllico;
  @override final String statut;
  @override final double prixEstime;
  @override final double? prixFinal;
  @override final String? modePaiement;
  @JsonKey(name: 'otpValide') @override final bool otpValide;
  @override final String? preuveLivraisonUrl;
  @override final double? noteLivreur;
  @override final bool urgent;
  @override final bool nuit;
  @override final double poids;
  @override final DateTime? dateCreation;
  @override final DateTime? dateLivraison;

  const LivraisonModel({
    this.id, this.client, this.livreur,
    this.codeSuivi,
    required this.pointDepart, required this.pointArrivee,
    this.vehicule, required this.mode, this.pointIllico,
    this.statut = 'en_attente', required this.prixEstime,
    this.prixFinal, this.modePaiement, this.otpValide = false,
    this.preuveLivraisonUrl, this.noteLivreur,
    this.urgent = false, this.nuit = false, this.poids = 1,
    this.dateCreation, this.dateLivraison,
  }) : super(
    id: id, client: client, livreur: livreur,
    codeSuivi: codeSuivi,
    pointDepart: pointDepart, pointArrivee: pointArrivee,
    vehicule: vehicule, mode: mode, pointIllico: pointIllico,
    statut: statut, prixEstime: prixEstime, prixFinal: prixFinal,
    modePaiement: modePaiement, otpValide: otpValide,
    preuveLivraisonUrl: preuveLivraisonUrl, noteLivreur: noteLivreur,
    urgent: urgent, nuit: nuit, poids: poids,
    dateCreation: dateCreation, dateLivraison: dateLivraison,
  );

  factory LivraisonModel.fromJson(Map<String, dynamic> j) => _$LivraisonModelFromJson(j);
  Map<String, dynamic> toJson() => _$LivraisonModelToJson(this);

  static dynamic _dynFromJson(dynamic v) => v;
  static dynamic _dynToJson(dynamic v) => v is Map ? v : v?.toString();
  static PointAdresse _pointFromJson(dynamic v) {
    if (v is Map<String, dynamic>) return PointAdresseModel.fromJson(v);
    return const PointAdresseModel(nomContact: '', adresse: '', telephoneContact: '', coordinates: [0, 0]);
  }
  static dynamic _pointToJson(PointAdresse v) {
    if (v is PointAdresseModel) return v.toJson();
    return {
      'nomContact': v.nomContact,
      'adresse': v.adresse,
      'telephoneContact': v.telephoneContact,
      'coordinates': v.coordinates
    };
  }
}
