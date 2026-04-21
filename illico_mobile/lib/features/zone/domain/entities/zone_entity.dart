import 'package:equatable/equatable.dart';
class ZoneEntity extends Equatable {
  final String? id;
  final String nom;
  final String? description;
  final double supplement;
  final bool actif;
  const ZoneEntity({this.id, required this.nom, this.description, this.supplement = 0, this.actif = true});
  @override List<Object?> get props => [id, nom];
}
