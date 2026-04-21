import 'package:equatable/equatable.dart';
class TarifEntity extends Equatable {
  final String? id;
  final dynamic vehicule;
  final dynamic zone;
  final double prixBase;
  final double coutKm;
  final double supplementUrgent;
  final double supplementNuit;
  final double supplementPoids;
  final double remisePointIllico;
  final bool actif;
  const TarifEntity({this.id, this.vehicule, this.zone, required this.prixBase, required this.coutKm,
    this.supplementUrgent = 0, this.supplementNuit = 0, this.supplementPoids = 0,
    this.remisePointIllico = 0, this.actif = true});
  @override List<Object?> get props => [id];
}
