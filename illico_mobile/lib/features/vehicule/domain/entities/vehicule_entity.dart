import 'package:equatable/equatable.dart';

class VehiculeEntity extends Equatable {
  final String? id;
  final String type;
  final double tarifBase;
  final double coutParKm;
  final double commission;
  final String? description;
  final bool actif;
  const VehiculeEntity({this.id, required this.type, required this.tarifBase,
    required this.coutParKm, required this.commission, this.description, this.actif = true});
  @override List<Object?> get props => [id, type];
}
