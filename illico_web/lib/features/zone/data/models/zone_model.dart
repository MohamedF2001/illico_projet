import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zone_entity.dart';
part 'zone_model.g.dart';

@JsonSerializable()
class ZoneModel extends ZoneEntity {
  @JsonKey(name: '_id') @override final String? id;
  @override final String nom;
  @override final String? description;
  @override final double supplement;
  @override final bool actif;
  const ZoneModel({this.id, required this.nom, this.description, this.supplement = 0, this.actif = true})
      : super(id: id, nom: nom, description: description, supplement: supplement, actif: actif);
  factory ZoneModel.fromJson(Map<String, dynamic> j) => _$ZoneModelFromJson(j);
  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);
}
