import 'package:equatable/equatable.dart';

class PointAdresse extends Equatable {
  final String adresse;
  final List<double> coordinates;
  const PointAdresse({required this.adresse, required this.coordinates});
  @override List<Object?> get props => [adresse, coordinates];
}

class LivraisonEntity extends Equatable {
  final String? id;
  final dynamic client;
  final dynamic livreur;
  final PointAdresse pointDepart;
  final PointAdresse pointArrivee;
  final dynamic vehicule;
  final String mode;
  final dynamic pointIllico;
  final String statut;
  final double prixEstime;
  final double? prixFinal;
  final String? modePaiement;
  final bool otpValide;
  final String? preuveLivraisonUrl;
  final double? noteLivreur;
  final bool urgent;
  final bool nuit;
  final double poids;
  final DateTime? dateCreation;
  final DateTime? dateLivraison;

  const LivraisonEntity({
    this.id, this.client, this.livreur,
    required this.pointDepart, required this.pointArrivee,
    this.vehicule, required this.mode, this.pointIllico,
    this.statut = 'en_attente', required this.prixEstime,
    this.prixFinal, this.modePaiement, this.otpValide = false,
    this.preuveLivraisonUrl, this.noteLivreur,
    this.urgent = false, this.nuit = false, this.poids = 1,
    this.dateCreation, this.dateLivraison,
  });

  bool get isActive => ['affecté','arrivé_pickup','colis_récupéré','déposé_en_point'].contains(statut);
  bool get isFinal  => ['livré','annulé','échoué'].contains(statut);

  @override List<Object?> get props => [id, statut];
}
