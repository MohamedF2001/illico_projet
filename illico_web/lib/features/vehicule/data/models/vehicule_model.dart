import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/vehicule_entity.dart';
part 'vehicule_model.g.dart';

@JsonSerializable()
class VehiculeModel extends VehiculeEntity {
  @JsonKey(name: '_id') @override final String? id;
  @override final String type;
  @override final double tarifBase;
  @override final double coutParKm;
  @override final double commission;
  @override final String? description;
  @override final bool actif;
  const VehiculeModel({this.id, required this.type, required this.tarifBase,
    required this.coutParKm, required this.commission, this.description, this.actif = true})
    : super(id: id, type: type, tarifBase: tarifBase, coutParKm: coutParKm,
        commission: commission, description: description, actif: actif);
  factory VehiculeModel.fromJson(Map<String, dynamic> j) => _$VehiculeModelFromJson(j);
  Map<String, dynamic> toJson() => _$VehiculeModelToJson(this);
}
